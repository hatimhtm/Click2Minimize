#!/bin/bash

# Setup a clean environment path that includes our mocks first
ORIG_PATH=$PATH
MOCKS_DIR="$(pwd)/mocks"
export PATH="$MOCKS_DIR:$ORIG_PATH"

# Create mock directory
mkdir -p "$MOCKS_DIR"

# Mock for xcodebuild
cat << 'MOCK' > "$MOCKS_DIR/xcodebuild"
#!/bin/bash
if [[ "$*" == *"clean"* ]]; then
    echo "mock xcodebuild clean"
else
    APP_NAME="Click2Hide"
    APP_PATH="build/Build/Products/Release/$APP_NAME.app"
    mkdir -p "$APP_PATH"
    echo "mock xcodebuild build"
fi
MOCK
chmod +x "$MOCKS_DIR/xcodebuild"

# Mock for hdiutil
cat << 'MOCK' > "$MOCKS_DIR/hdiutil"
#!/bin/bash
DMG_PATH="dist/Click2Minimize.dmg"
mkdir -p dist
touch "$DMG_PATH"
echo "mock hdiutil create"
MOCK
chmod +x "$MOCKS_DIR/hdiutil"

# Test function
run_test() {
    local test_name="$1"
    local codesign_exit_code="$2"
    local expected_exit_code="$3"
    local expected_output="$4"

    echo "Running test: $test_name"

    # Setup codesign mock
    cat << MOCK > "$MOCKS_DIR/codesign"
#!/bin/bash
if [ "$codesign_exit_code" -ne 0 ]; then
    echo "mock codesign failed"
    exit $codesign_exit_code
else
    echo "mock codesign success"
    exit 0
fi
MOCK

    chmod +x "$MOCKS_DIR/codesign"

    # Clean previous state
    rm -rf build dist temp_dmg_contents

    # Run the script
    output=$(./build_dmg.sh 2>&1)
    exit_code=$?

    if [ $exit_code -eq $expected_exit_code ]; then
        if [[ -z "$expected_output" || "$output" == *"$expected_output"* ]]; then
            echo "✅ PASSED"
        else
            echo "❌ FAILED: Output did not match expected."
            echo "Expected part: $expected_output"
            echo "Actual output: $output"
            exit 1
        fi
    else
        echo "❌ FAILED: Exit code $exit_code did not match expected $expected_exit_code."
        echo "Actual output: $output"
        exit 1
    fi
    echo ""
}

# Run tests
run_test "Happy Path" 0 0 "DMG created successfully"
run_test "Codesign Failure Path" 1 1 "Code signing failed. Exiting."

echo "All tests completed successfully!"

# Cleanup
rm -rf "$MOCKS_DIR" build dist temp_dmg_contents
