import XCTest
import ServiceManagement
@testable import Click2Minimize

class MockAppService: AppServiceProtocol {
    var status: SMAppService.Status = .notFound
    var registerCalled = false
    var unregisterCalled = false
    var shouldThrowError = false

    enum MockError: Error {
        case registrationFailed
    }

    func register() throws {
        registerCalled = true
        if shouldThrowError {
            throw MockError.registrationFailed
        }
        status = .enabled
    }

    func unregister() throws {
        unregisterCalled = true
        if shouldThrowError {
            throw MockError.registrationFailed
        }
        status = .notFound
    }
}

class AppDelegateTests: XCTestCase {

    func testRegisterLoginItemSuccess() {
        let appDelegate = AppDelegate()
        let mockService = MockAppService()
        appDelegate.appService = mockService

        appDelegate.registerLoginItem()

        XCTAssertTrue(mockService.registerCalled)
        XCTAssertFalse(mockService.unregisterCalled)
        XCTAssertEqual(mockService.status, .enabled)
    }

    func testRegisterLoginItemAlreadyEnabled() {
        let appDelegate = AppDelegate()
        let mockService = MockAppService()
        mockService.status = .enabled
        appDelegate.appService = mockService

        appDelegate.registerLoginItem()

        XCTAssertTrue(mockService.unregisterCalled)
        XCTAssertTrue(mockService.registerCalled)
    }

    func testRegisterLoginItemErrorPath() {
        let appDelegate = AppDelegate()
        let mockService = MockAppService()
        mockService.shouldThrowError = true
        appDelegate.appService = mockService

        // Calling this should safely catch the error and not crash
        appDelegate.registerLoginItem()

        XCTAssertTrue(mockService.registerCalled)
    }
}
