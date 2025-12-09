#!/bin/bash
set -e

# verify_modules.sh
# 
# Usage: ./verify_modules.sh [module_directory] [output_csv_file]
#
# This script scans a directory for OpenMRS module files (.omod),
# extracts their Module ID and Version, calculates a checksum,
# and outputs the results to the screen and optionally a CSV file.
#
# It is designed to run on systems with standard tools (unzip, perl, sha256sum/md5sum).
# Missing tools will be installed via apt-get if running with appropriate permissions.

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a package if missing
install_if_missing() {
    local cmd=$1
    local package=$2
    
    if ! command_exists "$cmd"; then
        echo "Installing $package (required for $cmd)..."
        if command_exists apt-get; then
            if [ "$EUID" -eq 0 ]; then
                apt-get update -qq && apt-get install -y "$package"
            else
                echo "Warning: $cmd not found and root access required to install $package."
                echo "Please run: sudo apt-get install $package"
                return 1
            fi
        else
            echo "Error: $cmd not found and apt-get not available. Please install $package manually."
            return 1
        fi
    fi
    return 0
}

# Check and install required tools
if ! install_if_missing unzip unzip; then
    exit 1
fi

if ! install_if_missing perl perl; then
    exit 1
fi

# Determine checksum command (prefer SHA256, fallback to MD5)
HASH_CMD=""
HASH_NAME=""

if command_exists sha256sum; then
    HASH_CMD="sha256sum"
    HASH_NAME="SHA256"
elif command_exists shasum; then
    HASH_CMD="shasum -a 256"
    HASH_NAME="SHA256"
elif command_exists md5sum; then
    HASH_CMD="md5sum"
    HASH_NAME="MD5"
elif command_exists md5; then
    HASH_CMD="md5 -r"
    HASH_NAME="MD5"
else
    # Try to install coreutils for checksum tools
    if command_exists apt-get; then
        if [ "$EUID" -eq 0 ]; then
            echo "Installing coreutils (required for checksum tools)..."
            apt-get update -qq && apt-get install -y coreutils
            # Re-check after installation
            if command_exists sha256sum; then
                HASH_CMD="sha256sum"
                HASH_NAME="SHA256"
            elif command_exists md5sum; then
                HASH_CMD="md5sum"
                HASH_NAME="MD5"
            fi
        else
            echo "Error: No suitable checksum tool found. Please run: sudo apt-get install coreutils"
            exit 1
        fi
    else
        echo "Error: No suitable checksum tool (sha256sum, shasum, md5sum, md5) found."
        exit 1
    fi
fi

if [ -z "$HASH_CMD" ]; then
    echo "Error: Could not determine checksum command."
    exit 1
fi

# Arguments
MODULE_DIR="${1:-.}"
OUTPUT_CSV="$2"

# Validation
if [ ! -d "$MODULE_DIR" ]; then
    echo "Error: Directory '$MODULE_DIR' does not exist."
    echo "Usage: $0 [module_directory] [output_csv_file]"
    exit 1
fi

# Create temporary file for collecting module data
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

echo "Analyzing modules in: $MODULE_DIR"
echo "Checksum Algorithm: $HASH_NAME"
echo "Collecting module information..."

count=0

# Collect data from all .omod files
for file in "$MODULE_DIR"/*.omod; do
    if [ ! -e "$file" ]; then
        if [ $count -eq 0 ]; then
            echo "No .omod files found in $MODULE_DIR"
            exit 0
        fi
        break
    fi
    
    count=$((count + 1))
    filename=$(basename "$file")
    
    # Get file metadata
    if command_exists stat; then
        # Try GNU stat first (Linux)
        if stat -c "%Y" "$file" >/dev/null 2>&1; then
            last_modified=$(stat -c "%Y" "$file")
            file_size=$(stat -c "%s" "$file")
            last_modified_readable=$(stat -c "%y" "$file" | cut -d'.' -f1)
        # Try BSD stat (macOS)
        elif stat -f "%m" "$file" >/dev/null 2>&1; then
            last_modified=$(stat -f "%m" "$file")
            file_size=$(stat -f "%z" "$file")
            last_modified_readable=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
        else
            last_modified=""
            file_size=$(ls -l "$file" | awk '{print $5}')
            last_modified_readable=$(ls -l "$file" | awk '{print $6, $7, $8}')
        fi
    else
        # Fallback to ls
        file_size=$(ls -l "$file" | awk '{print $5}')
        last_modified_readable=$(ls -l "$file" | awk '{print $6, $7, $8}')
        last_modified=""
    fi
    
    # Format file size in human-readable format
    if [ -n "$file_size" ]; then
        if [ "$file_size" -gt 1048576 ]; then
            file_size_human=$(echo "scale=2; $file_size / 1048576" | bc 2>/dev/null || echo "${file_size} bytes")
            if [ "$file_size_human" != "${file_size} bytes" ]; then
                file_size_display="${file_size_human} MB"
            else
                file_size_display="${file_size} bytes"
            fi
        elif [ "$file_size" -gt 1024 ]; then
            file_size_human=$(echo "scale=2; $file_size / 1024" | bc 2>/dev/null || echo "${file_size} bytes")
            if [ "$file_size_human" != "${file_size} bytes" ]; then
                file_size_display="${file_size_human} KB"
            else
                file_size_display="${file_size} bytes"
            fi
        else
            file_size_display="${file_size} bytes"
        fi
    else
        file_size_display="Unknown"
        file_size=""
    fi
    
    # 1. Extract config.xml
    if ! config_content=$(unzip -p "$file" config.xml 2>/dev/null); then
        echo "Warning: Could not read config.xml from $filename (or file is corrupted)" >&2
        # Store error entry with placeholder values
        echo "Unknown (Check $filename)|Unknown|N/A|$filename|$file_size|$file_size_display|$last_modified_readable|$last_modified" >> "$TEMP_FILE"
        continue
    fi
    
    # 2. Extract ID and Version using Perl for robust XML regex (handling multiline/whitespace)
    module_id=$(echo "$config_content" | perl -0777 -ne 'print $1 if /<id>\s*(.*?)\s*<\/id>/s')
    module_version=$(echo "$config_content" | perl -0777 -ne 'print $1 if /<version>\s*(.*?)\s*<\/version>/s')
    
    # Fallback/Cleanup
    if [ -z "$module_id" ]; then
        module_id="Unknown (Check $filename)"
    fi
    
    if [ -z "$module_version" ]; then
        module_version="Unknown"
    fi
    
    # 3. Calculate Checksum
    full_checksum=$($HASH_CMD "$file" | awk '{print $1}')
    
    # Store data: module_id|version|checksum|filename|file_size|file_size_human|last_modified_readable|last_modified_timestamp
    echo "$module_id|$module_version|$full_checksum|$filename|$file_size|$file_size_display|$last_modified_readable|$last_modified" >> "$TEMP_FILE"
done

# Sort by module ID (first field, delimited by |)
sort -t'|' -k1,1 "$TEMP_FILE" > "${TEMP_FILE}.sorted"
mv "${TEMP_FILE}.sorted" "$TEMP_FILE"

# Initialize CSV file if provided
if [ -n "$OUTPUT_CSV" ]; then
    # Create/Overwrite file with header
    echo "Module ID,Version,${HASH_NAME} Checksum,Filename,File Size (bytes),File Size (human),Last Modified,Last Modified (timestamp)" > "$OUTPUT_CSV"
fi

echo "===================================================================================================="
printf "%-35s | %-18s | %-12s | %-10s | %-19s | %s\n" "Module ID" "Version" "Checksum" "Size" "Last Modified" "Filename"
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------"

# Output sorted results
while IFS='|' read -r module_id module_version full_checksum filename file_size file_size_display last_modified_readable last_modified; do
    short_checksum=$(echo "$full_checksum" | cut -c1-8)
    display_id=$(echo "$module_id" | awk '{print substr($0, 1, 35)}')
    
    # Truncate last_modified_readable if too long
    last_mod_display=$(echo "$last_modified_readable" | awk '{print substr($0, 1, 19)}')
    
    printf "%-35s | %-18s | %-12s | %-10s | %-19s | %s\n" \
        "$display_id" \
        "$module_version" \
        "$short_checksum..." \
        "$file_size_display" \
        "$last_mod_display" \
        "$filename"
    
    if [ -n "$OUTPUT_CSV" ]; then
        # Escape commas in fields for CSV
        echo "$module_id,$module_version,$full_checksum,$filename,$file_size,$file_size_display,$last_modified_readable,$last_modified" >> "$OUTPUT_CSV"
    fi
done < "$TEMP_FILE"

echo "===================================================================================================="
echo "Processed $count modules (sorted alphabetically by Module ID)."
if [ -n "$OUTPUT_CSV" ]; then
    echo "Full results saved to: $OUTPUT_CSV"
fi
