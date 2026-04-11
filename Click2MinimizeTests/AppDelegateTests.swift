import XCTest
@testable import Click2Minimize
import Cocoa

class MockAXWindow: AXWindowProtocol {
    var isMinimizedValue: Bool?
    var setMinimizedResult: Bool = true
    var didCallSetMinimized = false
    var lastSetMinimizedValue: Bool?

    init(isMinimizedValue: Bool? = false) {
        self.isMinimizedValue = isMinimizedValue
    }

    func isMinimized() -> Bool? {
        return isMinimizedValue
    }

    func setMinimized(_ value: Bool) -> Bool {
        didCallSetMinimized = true
        lastSetMinimizedValue = value
        return setMinimizedResult
    }
}

class MockAXEnvironment: AXEnvironment {
    var windowsToReturn: [AXWindowProtocol]?

    init(windows: [AXWindowProtocol]? = nil) {
        self.windowsToReturn = windows
    }

    func getWindows(for processIdentifier: pid_t) -> [AXWindowProtocol]? {
        return windowsToReturn
    }
}

class AppDelegateTests: XCTestCase {

    func testMinimizeWindows_NoWindows_ReturnsFalse() {
        let env = MockAXEnvironment(windows: nil)
        let result = AppDelegate.minimizeWindows(processIdentifier: 1234, env: env)
        XCTAssertFalse(result)
    }

    func testMinimizeWindows_EmptyWindowsList_ReturnsFalse() {
        let env = MockAXEnvironment(windows: [])
        let result = AppDelegate.minimizeWindows(processIdentifier: 1234, env: env)
        XCTAssertFalse(result)
    }

    func testMinimizeWindows_WindowAlreadyMinimized_ReturnsFalse() {
        let window = MockAXWindow(isMinimizedValue: true)
        let env = MockAXEnvironment(windows: [window])

        let result = AppDelegate.minimizeWindows(processIdentifier: 1234, env: env)

        XCTAssertFalse(result)
        XCTAssertFalse(window.didCallSetMinimized)
    }

    func testMinimizeWindows_WindowUnminimized_MinimizesAndReturnsTrue() {
        let window = MockAXWindow(isMinimizedValue: false)
        let env = MockAXEnvironment(windows: [window])

        let result = AppDelegate.minimizeWindows(processIdentifier: 1234, env: env)

        XCTAssertTrue(result)
        XCTAssertTrue(window.didCallSetMinimized)
        XCTAssertEqual(window.lastSetMinimizedValue, true)
    }

    func testMinimizeWindows_MultipleWindows_MinimizesOnlyUnminimized_ReturnsTrue() {
        let window1 = MockAXWindow(isMinimizedValue: true)
        let window2 = MockAXWindow(isMinimizedValue: false)
        let env = MockAXEnvironment(windows: [window1, window2])

        let result = AppDelegate.minimizeWindows(processIdentifier: 1234, env: env)

        XCTAssertTrue(result)
        XCTAssertFalse(window1.didCallSetMinimized)
        XCTAssertTrue(window2.didCallSetMinimized)
    }

    func testMinimizeWindows_SetMinimizedFails_ReturnsFalse() {
        let window = MockAXWindow(isMinimizedValue: false)
        window.setMinimizedResult = false
        let env = MockAXEnvironment(windows: [window])

        let result = AppDelegate.minimizeWindows(processIdentifier: 1234, env: env)

        XCTAssertFalse(result)
        XCTAssertTrue(window.didCallSetMinimized)
    }
}
