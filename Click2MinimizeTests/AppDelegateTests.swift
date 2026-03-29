import XCTest
import ServiceManagement
@testable import Click2Minimize

enum MockError: Error {
    case mockRegistrationError
}

class MockLoginItemManager: LoginItemManager {
    var status: SMAppService.Status = .notRegistered
    var shouldThrowError = false
    var registerCallCount = 0
    var unregisterCallCount = 0

    func register() throws {
        registerCallCount += 1
        if shouldThrowError {
            throw MockError.mockRegistrationError
        }
        status = .enabled
    }

    func unregister() throws {
        unregisterCallCount += 1
        status = .notRegistered
    }
}

final class AppDelegateTests: XCTestCase {

    func testRegisterLoginItemErrorHandling() {
        // Arrange
        let appDelegate = AppDelegate()
        let mockManager = MockLoginItemManager()
        mockManager.shouldThrowError = true
        appDelegate.loginItemManager = mockManager

        // Ensure no error initially
        XCTAssertNil(appDelegate.loginItemRegistrationError)

        // Act
        appDelegate.registerLoginItem()

        // Assert
        XCTAssertNotNil(appDelegate.loginItemRegistrationError, "The error should be caught and stored in loginItemRegistrationError")
        XCTAssertTrue(appDelegate.loginItemRegistrationError is MockError, "The stored error should be the mock error thrown")
        XCTAssertEqual(mockManager.registerCallCount, 1, "The register method should have been called once")
    }

    func testRegisterLoginItemSuccess() {
        // Arrange
        let appDelegate = AppDelegate()
        let mockManager = MockLoginItemManager()
        mockManager.shouldThrowError = false
        appDelegate.loginItemManager = mockManager

        // Ensure no error initially
        XCTAssertNil(appDelegate.loginItemRegistrationError)

        // Act
        appDelegate.registerLoginItem()

        // Assert
        XCTAssertNil(appDelegate.loginItemRegistrationError, "There should be no error on successful registration")
        XCTAssertEqual(mockManager.registerCallCount, 1, "The register method should have been called once")
        XCTAssertEqual(mockManager.status, .enabled, "The status should be enabled after successful registration")
    }

    func testRegisterLoginItemUnregistersIfAlreadyEnabled() {
        // Arrange
        let appDelegate = AppDelegate()
        let mockManager = MockLoginItemManager()
        mockManager.shouldThrowError = false
        mockManager.status = .enabled
        appDelegate.loginItemManager = mockManager

        // Act
        appDelegate.registerLoginItem()

        // Assert
        XCTAssertNil(appDelegate.loginItemRegistrationError)
        XCTAssertEqual(mockManager.unregisterCallCount, 1, "The unregister method should have been called once because it was already enabled")
        XCTAssertEqual(mockManager.registerCallCount, 1, "The register method should have been called once")
    }
}
