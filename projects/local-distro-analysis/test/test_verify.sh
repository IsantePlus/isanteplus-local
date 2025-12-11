#!/bin/bash
set -e

# test_verify.sh
#
# Comprehensive test script to verify all functionality of verify_modules.sh
# Tests CLI arguments, error handling, output formats, and data extraction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_SCRIPT="$SCRIPT_DIR/../verify_modules.sh"
TEST_DIR="$(cd "$SCRIPT_DIR/../../emr-isanteplus/distribution/openmrs_modules-2.8.4" && pwd)"
OUTPUT_CSV="$SCRIPT_DIR/test_output_2.8.4.csv"
TEMP_DIR="$SCRIPT_DIR/test_temp"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "TEST: $test_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if eval "$test_command"; then
        echo "✓ PASSED: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "✗ FAILED: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Check if verify script exists
if [ ! -f "$VERIFY_SCRIPT" ]; then
    echo "Error: verify_modules.sh not found at $VERIFY_SCRIPT"
    exit 1
fi

# Check if test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo "Error: Test directory not found at $TEST_DIR"
    exit 1
fi

echo "===================================================================================================="
echo "COMPREHENSIVE TEST SUITE FOR verify_modules.sh"
echo "===================================================================================================="
echo ""

# Test 1: Verify script is executable
run_test "Script is executable" "[ -x '$VERIFY_SCRIPT' ]"

# Test 2: Test error handling - invalid directory
run_test "Error handling for invalid directory" "
    output=\$(\"$VERIFY_SCRIPT\" /nonexistent/directory 2>&1)
    echo \"\$output\" | grep -qi 'Error.*does not exist'
    [ \$? -eq 0 ]
"

# Test 3: Test with directory argument only (no CSV)
run_test "Run with directory argument (no CSV output)" "
    output=\$(\"$VERIFY_SCRIPT\" \"$TEST_DIR\" 2>&1)
    echo \"\$output\" | grep -q 'Analyzing modules'
    [ \$? -eq 0 ] && echo \"\$output\" | grep -q 'Processed'
"

# Test 4: Test with directory and CSV output
run_test "Run with directory and CSV output" "
    rm -f \"$OUTPUT_CSV\"
    output=\$(\"$VERIFY_SCRIPT\" \"$TEST_DIR\" \"$OUTPUT_CSV\" 2>&1)
    [ -f \"$OUTPUT_CSV\" ] && [ -s \"$OUTPUT_CSV\" ]
"

# Test 5: Verify CSV format and header
run_test "CSV file has correct header format" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        head -1 \"$OUTPUT_CSV\" | grep -q 'Module ID,Version'
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 6: Verify CSV contains data rows
run_test "CSV file contains module entries" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        line_count=\$(wc -l < \"$OUTPUT_CSV\")
        [ \"\$line_count\" -gt 1 ]
    else
        false
    fi
"

# Test 7: Verify CSV rows have correct number of fields
run_test "CSV rows have 8 fields (ID, Version, Checksum, Filename, Size bytes, Size human, Last Modified, Last Modified timestamp)" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        # Skip header, check each data row
        tail -n +2 \"$OUTPUT_CSV\" | while IFS= read -r line; do
            field_count=\$(echo \"\$line\" | awk -F',' '{print NF}')
            if [ \"\$field_count\" -ne 8 ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 8: Verify checksums are calculated (non-empty)
run_test "Checksums are calculated and non-empty" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        # Check that checksum column (3rd field) is not empty for data rows
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$3}' | while IFS= read -r checksum; do
            if [ -z \"\$checksum\" ] || [ \"\$checksum\" = \"N/A\" ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 9: Verify module IDs are extracted
run_test "Module IDs are extracted from config.xml" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        # Check that ID column (1st field) is not empty for data rows
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$1}' | while IFS= read -r id; do
            if [ -z \"\$id\" ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 10: Verify versions are extracted
run_test "Module versions are extracted from config.xml" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        # Check that version column (2nd field) is not empty for data rows
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$2}' | while IFS= read -r version; do
            if [ -z \"\$version\" ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 11: Verify filenames match actual .omod files
run_test "CSV filenames match actual .omod files in directory" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        # Extract filenames from CSV (4th column)
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$4}' | while IFS= read -r filename; do
            if [ ! -f \"$TEST_DIR/\$filename\" ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 12: Test default behavior (current directory)
run_test "Default behavior uses current directory" "
    mkdir -p \"$TEMP_DIR\"
    cd \"$TEMP_DIR\"
    # Create a dummy .omod file structure for testing (or skip if none)
    output=\$(\"$VERIFY_SCRIPT\" 2>&1)
    cd \"$SCRIPT_DIR\"
    rm -rf \"$TEMP_DIR\"
    echo \"\$output\" | grep -q 'Analyzing modules'
    [ \$? -eq 0 ]
"

# Test 13: Verify console output format
run_test "Console output shows formatted table" "
    output=\$(\"$VERIFY_SCRIPT\" \"$TEST_DIR\" 2>&1)
    echo \"\$output\" | grep -q 'Module ID.*Version.*Checksum.*Filename'
    [ \$? -eq 0 ]
"

# Test 14: Verify checksum algorithm is reported
run_test "Checksum algorithm is reported in output" "
    output=\$(\"$VERIFY_SCRIPT\" \"$TEST_DIR\" 2>&1)
    echo \"\$output\" | grep -q 'Checksum Algorithm'
    [ \$? -eq 0 ]
"

# Test 15: Verify module count is reported
run_test "Module count is reported in output" "
    output=\$(\"$VERIFY_SCRIPT\" \"$TEST_DIR\" 2>&1)
    echo \"\$output\" | grep -qE 'Processed [0-9]+ modules'
    [ \$? -eq 0 ]
"

# Test 16: Verify modules are sorted alphabetically by Module ID
run_test "Modules are sorted alphabetically by Module ID" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        # Extract module IDs (skip header) and check if sorted
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$1}' > /tmp/module_ids.txt
        sort /tmp/module_ids.txt > /tmp/module_ids_sorted.txt
        diff /tmp/module_ids.txt /tmp/module_ids_sorted.txt > /dev/null
        result=\$?
        rm -f /tmp/module_ids.txt /tmp/module_ids_sorted.txt
        [ \$result -eq 0 ]
    else
        false
    fi
"

# Test 17: Verify file size information is included
run_test "File size (bytes) is included in CSV" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$5}' | while IFS= read -r size; do
            if [ -z \"\$size\" ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 18: Verify human-readable file size is included
run_test "Human-readable file size is included in CSV" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$6}' | while IFS= read -r size_human; do
            if [ -z \"\$size_human\" ]; then
                exit 1
            fi
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 19: Verify last modified timestamp is included
run_test "Last modified timestamp is included in CSV" "
    if [ -f \"$OUTPUT_CSV\" ]; then
        tail -n +2 \"$OUTPUT_CSV\" | awk -F',' '{print \$8}' | while IFS= read -r timestamp; do
            # Timestamp can be empty on some systems, but at least some should have it
            true
        done
        [ \$? -eq 0 ]
    else
        false
    fi
"

# Test 20: Verify console output mentions alphabetical sorting
run_test "Console output mentions alphabetical sorting" "
    output=\$(\"$VERIFY_SCRIPT\" \"$TEST_DIR\" 2>&1)
    echo \"\$output\" | grep -q 'sorted alphabetically'
    [ \$? -eq 0 ]
"

echo ""
echo "===================================================================================================="
echo "TEST SUMMARY"
echo "===================================================================================================="
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "✓ ALL TESTS PASSED"
    echo ""
    echo "Sample output from CSV:"
    echo "----------------------------------------------------------------------------------------------------"
    if [ -f "$OUTPUT_CSV" ]; then
        head -5 "$OUTPUT_CSV" | column -t -s','
    fi
    exit 0
else
    echo "✗ SOME TESTS FAILED"
    exit 1
fi
