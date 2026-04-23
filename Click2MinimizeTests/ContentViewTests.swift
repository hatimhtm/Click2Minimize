import XCTest
import SwiftUI
@testable import Click2Minimize

final class ContentViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "ClickToMinimizeEnabled")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "ClickToMinimizeEnabled")
        super.tearDown()
    }

    func testContentViewInitializationSetsDefaultUserDefaults() {
        // Given that "ClickToMinimizeEnabled" is nil initially
        XCTAssertNil(UserDefaults.standard.object(forKey: "ClickToMinimizeEnabled"))

        // When we instantiate ContentView
        _ = ContentView()

        // Then it should set the default value to true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled"))
    }

    func testContentViewInitializationPreservesExistingUserDefaults() {
        // Given that "ClickToMinimizeEnabled" is set to false initially
        UserDefaults.standard.set(false, forKey: "ClickToMinimizeEnabled")

        // When we instantiate ContentView
        _ = ContentView()

        // Then it should preserve the existing false value
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled"))
    }
}
