#!/bin/bash

# Setup
TEST_DIR=$(pwd)
MOCK_BIN="$TEST_DIR/tests/mock_bin"
export PATH="$MOCK_BIN:$PATH"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Running tests for build_dmg.sh..."
FAILED=0

# Test 1: Happy Path
echo "Test 1: Happy Path (DMG created successfully)"
rm -rf dist build
./build_dmg.sh > /tmp/output_happy.log 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && grep -q "DMG created successfully at" /tmp/output_happy.log; then
  echo -e "${GREEN}✓ Test 1 Passed${NC}"
else
  echo -e "${RED}✗ Test 1 Failed${NC}"
  echo "Exit code: $EXIT_CODE"
  echo "Output:"
  cat /tmp/output_happy.log
  FAILED=1
fi

# Test 2: Error Path - hdiutil fails (no DMG created)
echo "Test 2: Error Path (hdiutil fails, no DMG created)"
rm -rf dist build
export FAIL_HDIUTIL=1
./build_dmg.sh > /tmp/output_error.log 2>&1
EXIT_CODE=$?
unset FAIL_HDIUTIL

if [ $EXIT_CODE -eq 1 ] && grep -q "Failed to create DMG." /tmp/output_error.log; then
  echo -e "${GREEN}✓ Test 2 Passed${NC}"
else
  echo -e "${RED}✗ Test 2 Failed${NC}"
  echo "Exit code: $EXIT_CODE"
  echo "Output:"
  cat /tmp/output_error.log
  FAILED=1
fi

if [ $FAILED -ne 0 ]; then
  echo -e "${RED}Some tests failed!${NC}"
  # exit with code 1, but wrap in a function if we need to mock exit
  false
else
  echo -e "${GREEN}All tests passed successfully!${NC}"
  true
fi
