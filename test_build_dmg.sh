#!/bin/bash

# test_build_dmg.sh
# Tests the build_dmg.sh script

# Create a temporary directory for mocks
MOCK_DIR=$(mktemp -d)
export PATH="$MOCK_DIR:$PATH"

setup_mocks() {
    # Mock xcodebuild
    cat << "MOCK" > "$MOCK_DIR/xcodebuild"
#!/bin/bash
if [[ "\$*" == *"clean"* ]]; then
    exit 0
fi
# Simulate successful build by creating the expected app directory
mkdir -p build/Build/Products/Release/Click2Minimize.app
exit 0
MOCK
    chmod +x "$MOCK_DIR/xcodebuild"

    # Mock codesign
    cat << "MOCK" > "$MOCK_DIR/codesign"
#!/bin/bash
exit 0
MOCK
    chmod +x "$MOCK_DIR/codesign"

    # Mock hdiutil
    cat << "MOCK" > "$MOCK_DIR/hdiutil"
#!/bin/bash
# Simulate successful DMG creation
mkdir -p dist
touch dist/Click2Minimize.dmg
exit 0
MOCK
    chmod +x "$MOCK_DIR/hdiutil"
}

cleanup() {
    rm -rf "$MOCK_DIR"
    rm -rf build dist temp_dmg_contents
}

cleanup_test() {
    rm -rf build dist temp_dmg_contents
}

# Run setup
setup_mocks

# --- Test 1: Successful DMG creation ---
echo "Running Test 1: Successful DMG creation..."
cleanup_test

if bash ./build_dmg.sh | grep -q "DMG created successfully"; then
    echo "✅ Test 1 Passed"
else
    echo "❌ Test 1 Failed: Expected successful DMG creation message."
    cleanup
    exit 1
fi

# --- Test 2: DMG creation fails (file not created) ---
echo "Running Test 2: Failed DMG creation..."
cleanup_test

# Modify hdiutil mock to simulate failure
cat << "MOCK" > "$MOCK_DIR/hdiutil"
#!/bin/bash
# Simulate failure by not creating the DMG file and returning an error
exit 1
MOCK
chmod +x "$MOCK_DIR/hdiutil"

OUTPUT=$(bash ./build_dmg.sh 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 1 ] && echo "$OUTPUT" | grep -q "Failed to create DMG"; then
    echo "✅ Test 2 Passed"
else
    echo "❌ Test 2 Failed: Expected script to fail with exit code 1 and error message."
    echo "Exit code: $EXIT_CODE"
    echo "Output: $OUTPUT"
    cleanup
    exit 1
fi

cleanup
echo "🎉 All tests passed successfully!"
