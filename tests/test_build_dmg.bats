#!/usr/bin/env bats

setup() {
    export MOCK_BIN_DIR="$BATS_TMPDIR/mock_bin_$$"
    mkdir -p "$MOCK_BIN_DIR"
    export PATH="$MOCK_BIN_DIR:$PATH"

    # Mock xcodebuild
    echo '#!/bin/bash' > "$MOCK_BIN_DIR/xcodebuild"
    echo 'if [ "$MOCK_XCODEBUILD_FAIL" = "1" ]; then exit 0; fi' >> "$MOCK_BIN_DIR/xcodebuild"
    echo 'if [[ "$*" == *"clean"* ]]; then exit 0; fi' >> "$MOCK_BIN_DIR/xcodebuild"
    echo 'mkdir -p build/Build/Products/Release/Click2Hide.app' >> "$MOCK_BIN_DIR/xcodebuild"
    chmod +x "$MOCK_BIN_DIR/xcodebuild"

    # Mock codesign
    echo '#!/bin/bash' > "$MOCK_BIN_DIR/codesign"
    echo 'if [ "$MOCK_CODESIGN_FAIL" = "1" ]; then exit 1; fi' >> "$MOCK_BIN_DIR/codesign"
    chmod +x "$MOCK_BIN_DIR/codesign"

    # Mock hdiutil
    echo '#!/bin/bash' > "$MOCK_BIN_DIR/hdiutil"
    echo 'if [ "$MOCK_HDIUTIL_FAIL" = "1" ]; then exit 0; fi' >> "$MOCK_BIN_DIR/hdiutil"
    echo 'mkdir -p dist' >> "$MOCK_BIN_DIR/hdiutil"
    echo 'touch dist/Click2Minimize.dmg' >> "$MOCK_BIN_DIR/hdiutil"
    chmod +x "$MOCK_BIN_DIR/hdiutil"

    export WORK_DIR="$BATS_TMPDIR/workspace_$$"
    mkdir -p "$WORK_DIR"
    cp "$BATS_TEST_DIRNAME/../build_dmg.sh" "$WORK_DIR/"
    cd "$WORK_DIR"
}

teardown() {
    rm -rf "$MOCK_BIN_DIR"
    rm -rf "$WORK_DIR"
}

@test "successful build creates DMG" {
    run ./build_dmg.sh
    [ "$status" -eq 0 ]
    [ -f "dist/Click2Minimize.dmg" ]
    echo "$output" | grep "DMG created successfully"
}

@test "build fails if xcodebuild does not create app dir" {
    export MOCK_XCODEBUILD_FAIL=1
    run ./build_dmg.sh
    [ "$status" -eq 1 ]
    echo "$output" | grep "Build failed. Exiting."
}

@test "build fails if codesign fails" {
    export MOCK_CODESIGN_FAIL=1
    run ./build_dmg.sh
    [ "$status" -eq 1 ]
    echo "$output" | grep "Code signing failed. Exiting."
}

@test "build fails if hdiutil does not create DMG" {
    export MOCK_HDIUTIL_FAIL=1
    run ./build_dmg.sh
    [ "$status" -eq 1 ]
    echo "$output" | grep "Failed to create DMG."
}
