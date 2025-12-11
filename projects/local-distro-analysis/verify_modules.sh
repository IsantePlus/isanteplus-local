#!/usr/bin/env bash
#
# verify_modules.sh - Analyze OpenMRS iSantePlus module files
#
# Scans a directory for .omod files, extracts module ID/version from config.xml,
# calculates checksums, and outputs results to console and optionally CSV.
#
# Usage: verify_modules.sh [OPTIONS] [DIRECTORY] [OUTPUT_CSV]
#   -h, --help          Show help
#   -v, --version       Show version
#   -V, --verbose       Enable verbose output
#   -q, --quiet         Suppress non-error output
#   -o, --output FILE   Specify output CSV file
#   --no-auto-install   Don't auto-install missing dependencies

set -uo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

# Options
MODULE_DIR=""
OUTPUT_CSV=""
VERBOSE=false
QUIET=false
AUTO_INSTALL=true

# Colors
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' NC=''
fi

error() { echo -e "${RED}Error:${NC} $*" >&2; }
warning() { [[ "$QUIET" == false ]] && echo -e "${YELLOW}Warning:${NC} $*" >&2; }
info() { [[ "$QUIET" == false ]] && echo "$*"; }
verbose() { [[ "$VERBOSE" == true ]] && echo -e "${GREEN}[VERBOSE]${NC} $*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [DIRECTORY] [OUTPUT_CSV]

Analyze OpenMRS iSantePlus module files (.omod) in a directory.

Arguments:
  DIRECTORY           Directory containing .omod files (default: current directory)
  OUTPUT_CSV          Optional CSV file path for output

Options:
  -h, --help          Show this help message
  -v, --version       Show version information
  -V, --verbose       Enable verbose output
  -q, --quiet         Suppress non-error output
  -o, --output FILE   Specify output CSV file
  --no-auto-install   Don't attempt to auto-install missing dependencies

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME /path/to/modules
  $SCRIPT_NAME /path/to/modules output.csv
  $SCRIPT_NAME -o report.csv /path/to/modules
EOF
}

version() { echo "$SCRIPT_NAME version $VERSION"; }

install_if_missing() {
    local cmd=$1 package=$2
    
    command_exists "$cmd" && return 0
    
    [[ "$AUTO_INSTALL" == false ]] && {
        error "$cmd not found. Install: sudo apt-get install $package"
        return 1
    }
    
    command_exists apt-get || {
        error "$cmd not found. Install: sudo apt-get install $package"
        return 1
    }
    
    [[ "$EUID" -ne 0 ]] && {
        warning "$cmd not found. Run: sudo apt-get install $package"
        return 1
    }
    
    info "Installing $package..."
    apt-get update -qq && apt-get install -y "$package"
}

setup_checksum() {
    if command_exists sha256sum; then
        echo "sha256sum|SHA256"
    elif command_exists shasum; then
        echo "shasum -a 256|SHA256"
    elif command_exists md5sum; then
        echo "md5sum|MD5"
    elif command_exists md5; then
        echo "md5 -r|MD5"
    else
        if command_exists apt-get && [[ "$EUID" -eq 0 ]]; then
            info "Installing coreutils..."
            apt-get update -qq && apt-get install -y coreutils
            command_exists sha256sum && echo "sha256sum|SHA256" && return 0
            command_exists md5sum && echo "md5sum|MD5" && return 0
        fi
        error "No checksum tool found. Install: sudo apt-get install coreutils"
        return 1
    fi
}

get_file_size() {
    local file="$1"
    if stat -c "%s" "$file" >/dev/null 2>&1; then
        stat -c "%s" "$file"
    elif stat -f "%z" "$file" >/dev/null 2>&1; then
        stat -f "%z" "$file"
    else
        ls -l "$file" | awk '{print $5}'
    fi
}

get_last_modified() {
    local file="$1"
    if stat -c "%Y" "$file" >/dev/null 2>&1; then
        stat -c "%Y" "$file"
    elif stat -f "%m" "$file" >/dev/null 2>&1; then
        stat -f "%m" "$file"
    else
        echo ""
    fi
}

get_last_modified_readable() {
    local file="$1"
    if stat -c "%y" "$file" >/dev/null 2>&1; then
        stat -c "%y" "$file" | cut -d'.' -f1
    elif stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" >/dev/null 2>&1; then
        stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file"
    else
        ls -l "$file" | awk '{print $6, $7, $8}'
    fi
}

format_size() {
    local size="$1"
    [[ -z "$size" ]] && echo "Unknown" && return
    
    if [[ "$size" -gt 1048576 ]]; then
        local mb=$(echo "scale=2; $size / 1048576" | bc 2>/dev/null || echo "")
        [[ -n "$mb" ]] && echo "${mb} MB" || echo "${size} bytes"
    elif [[ "$size" -gt 1024 ]]; then
        local kb=$(echo "scale=2; $size / 1024" | bc 2>/dev/null || echo "")
        [[ -n "$kb" ]] && echo "${kb} KB" || echo "${size} bytes"
    else
        echo "${size} bytes"
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            -v|--version) version; exit 0 ;;
            -V|--verbose) VERBOSE=true; shift ;;
            -q|--quiet) QUIET=true; shift ;;
            -o|--output)
                [[ -z "${2:-}" ]] && { error "Option $1 requires an argument"; usage; exit 2; }
                OUTPUT_CSV="$2"; shift 2 ;;
            --no-auto-install) AUTO_INSTALL=false; shift ;;
            --) shift; break ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2 ;;
            *)
                [[ -z "$MODULE_DIR" ]] && MODULE_DIR="$1" || OUTPUT_CSV="$1"
                shift ;;
        esac
    done
    
    [[ -z "$MODULE_DIR" ]] && MODULE_DIR="."
}

main() {
    parse_args "$@"
    
    # Validate directory first (before installing dependencies)
    if [[ ! -d "$MODULE_DIR" ]]; then
        error "Directory does not exist: $MODULE_DIR"
        exit 1
    fi
    
    install_if_missing unzip unzip || exit 3
    install_if_missing perl perl || exit 3
    
    local checksum_info
    checksum_info=$(setup_checksum) || exit 3
    HASH_CMD="${checksum_info%%|*}"
    HASH_NAME="${checksum_info##*|}"
    
    if [[ ! -r "$MODULE_DIR" ]]; then
        error "Directory not readable: $MODULE_DIR"
        exit 1
    fi
    
    if [[ -n "$OUTPUT_CSV" ]]; then
        local out_dir=$(dirname "$OUTPUT_CSV")
        [[ "$out_dir" != "." ]] && [[ ! -d "$out_dir" ]] && {
            error "Output directory does not exist: $out_dir"
            exit 1
        }
    fi
    
    local temp_file
    temp_file=$(mktemp)
    trap "rm -f $temp_file" EXIT INT TERM
    
    info "Analyzing modules in: $MODULE_DIR"
    info "Checksum Algorithm: $HASH_NAME"
    verbose "Collecting module information..."
    
    local count=0 error_count=0
    
    for file in "$MODULE_DIR"/*.omod; do
        [[ ! -e "$file" ]] && {
            [[ $count -eq 0 ]] && { error "No .omod files found in $MODULE_DIR"; exit 1; }
            break
        }
        
        local filename=$(basename "$file")
        verbose "Processing: $filename"
        
        local file_size=$(get_file_size "$file")
        local file_size_display=$(format_size "$file_size")
        local last_modified=$(get_last_modified "$file")
        local last_modified_readable=$(get_last_modified_readable "$file")
        
        local config_content
        if ! config_content=$(unzip -p "$file" config.xml 2>/dev/null); then
            warning "Could not read config.xml from $filename"
            echo "Unknown (Check $filename)|Unknown|N/A|$filename|$file_size|$file_size_display|$last_modified_readable|$last_modified" >> "$temp_file"
            error_count=$((error_count + 1))
            count=$((count + 1))
            continue
        fi
        
        local module_id=$(echo "$config_content" | perl -0777 -ne 'print $1 if /<id>\s*(.*?)\s*<\/id>/s' 2>/dev/null || echo "")
        [[ -z "$module_id" ]] && module_id="Unknown (Check $filename)"
        
        local module_version=$(echo "$config_content" | perl -0777 -ne 'print $1 if /<version>\s*(.*?)\s*<\/version>/s' 2>/dev/null || echo "")
        [[ -z "$module_version" ]] && module_version="Unknown"
        
        local full_checksum=$($HASH_CMD "$file" | awk '{print $1}')
        
        echo "$module_id|$module_version|$full_checksum|$filename|$file_size|$file_size_display|$last_modified_readable|$last_modified" >> "$temp_file"
        count=$((count + 1))
    done
    
    sort -t'|' -k1,1 "$temp_file" > "${temp_file}.sorted"
    mv "${temp_file}.sorted" "$temp_file"
    
    [[ -n "$OUTPUT_CSV" ]] && echo "Module ID,Version,${HASH_NAME} Checksum,Filename,File Size (bytes),File Size (human),Last Modified,Last Modified (timestamp)" > "$OUTPUT_CSV"
    
    info "===================================================================================================="
    printf "%-35s | %-18s | %-12s | %-10s | %-19s | %s\n" "Module ID" "Version" "Checksum" "Size" "Last Modified" "Filename"
    info "--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    
    while IFS='|' read -r module_id module_version full_checksum filename file_size file_size_display last_modified_readable last_modified; do
        local short_checksum=$(echo "$full_checksum" | cut -c1-8)
        local display_id=$(echo "$module_id" | awk '{print substr($0, 1, 35)}')
        local last_mod_display=$(echo "$last_modified_readable" | awk '{print substr($0, 1, 19)}')
        
        printf "%-35s | %-18s | %-12s | %-10s | %-19s | %s\n" \
            "$display_id" "$module_version" "$short_checksum..." "$file_size_display" "$last_mod_display" "$filename"
        
        [[ -n "$OUTPUT_CSV" ]] && echo "$module_id,$module_version,$full_checksum,$filename,$file_size,$file_size_display,$last_modified_readable,$last_modified" >> "$OUTPUT_CSV"
    done < "$temp_file"
    
    info "===================================================================================================="
    info "Processed $count modules (sorted alphabetically by Module ID)."
    [[ $error_count -gt 0 ]] && warning "$error_count module(s) had errors."
    [[ -n "$OUTPUT_CSV" ]] && info "Full results saved to: $OUTPUT_CSV"
}

main "$@"
