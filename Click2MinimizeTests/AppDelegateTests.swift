import XCTest
@testable import Click2Minimize

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }

    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }

    enum MockError: Error, LocalizedError {
        case registrationFailed

        var errorDescription: String? {
            return "Mock registration failed"
        }
    }

    func testRegisterLoginItem_Success() {
        // Arrange
        var handlerCalled = false
        appDelegate.loginItemRegistrationHandler = {
            handlerCalled = true
        }

        // Act
        appDelegate.registerLoginItem()

        // Assert
        XCTAssertTrue(handlerCalled, "The login item registration handler should be called")
        XCTAssertNil(appDelegate.lastLoginItemError, "There should be no error on successful registration")
    }

    func testRegisterLoginItem_Error() {
        // Arrange
        var handlerCalled = false
        appDelegate.loginItemRegistrationHandler = {
            handlerCalled = true
            throw MockError.registrationFailed
        }

        // Act
        appDelegate.registerLoginItem()

        // Assert
        XCTAssertTrue(handlerCalled, "The login item registration handler should be called")
        XCTAssertNotNil(appDelegate.lastLoginItemError, "The lastLoginItemError should not be nil")
        XCTAssertEqual(appDelegate.lastLoginItemError?.localizedDescription, MockError.registrationFailed.localizedDescription, "The error localized description should match")
    }
}
