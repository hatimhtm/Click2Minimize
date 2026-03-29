import re
import sys

def verify_app_delegate():
    print("Verifying AppDelegate.swift...")
    try:
        with open("Click2Minimize/AppDelegate.swift", "r") as f:
            content = f.read()

        if "protocol LoginItemManager" not in content:
            print("❌ Failed: LoginItemManager protocol missing.")
            return False

        if "class SystemLoginItemManager: LoginItemManager" not in content:
            print("❌ Failed: SystemLoginItemManager missing.")
            return False

        if "var loginItemManager: LoginItemManager" not in content:
            print("❌ Failed: loginItemManager property missing in AppDelegate.")
            return False

        if "var loginItemRegistrationError: Error?" not in content:
            print("❌ Failed: loginItemRegistrationError observable state missing in AppDelegate.")
            return False

        if "try loginItemManager.register()" not in content:
            print("❌ Failed: registerLoginItem not updated to use loginItemManager.")
            return False

        print("✅ AppDelegate.swift verified structurally.")
        return True
    except FileNotFoundError:
        print("❌ Failed: AppDelegate.swift not found.")
        return False

def verify_app_delegate_tests():
    print("Verifying AppDelegateTests.swift...")
    try:
        with open("Click2MinimizeTests/AppDelegateTests.swift", "r") as f:
            content = f.read()

        if "class MockLoginItemManager: LoginItemManager" not in content:
            print("❌ Failed: MockLoginItemManager missing.")
            return False

        if "func testRegisterLoginItemErrorHandling" not in content:
            print("❌ Failed: testRegisterLoginItemErrorHandling missing.")
            return False

        print("✅ AppDelegateTests.swift verified structurally.")
        return True
    except FileNotFoundError:
        print("❌ Failed: AppDelegateTests.swift not found.")
        return False

if __name__ == "__main__":
    success = verify_app_delegate() and verify_app_delegate_tests()
    if success:
        print("🎉 All structural verifications passed!")
        sys.exit(0)
    else:
        print("💥 Structural verifications failed.")
        sys.exit(1)
