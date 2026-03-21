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
        // Clear UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "ClickToMinimizeEnabled")
        super.tearDown()
    }

    func testContentViewDefaultUserDefaultsValue() {
        // Arrange
        // Ensure UserDefaults is empty
        XCTAssertNil(UserDefaults.standard.object(forKey: "ClickToMinimizeEnabled"))

        // Act
        // Initializing the view should trigger the @State default value logic
        let _ = ContentView()

        // Assert
        // Verify that the default value (true) was set in UserDefaults
        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertTrue(isEnabled, "isClickToMinimizeEnabled should default to true when UserDefaults is empty")
    }

    func testContentViewRespectsExistingUserDefaultsValueFalse() {
        // Arrange
        // Set an existing value in UserDefaults to false
        UserDefaults.standard.set(false, forKey: "ClickToMinimizeEnabled")

        // Act
        // Initializing the view should read the existing value, not overwrite it with the default
        let _ = ContentView()

        // Assert
        // Verify that the value remains false
        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertFalse(isEnabled, "ContentView should respect existing false value in UserDefaults")
    }

    func testContentViewRespectsExistingUserDefaultsValueTrue() {
        // Arrange
        // Set an existing value in UserDefaults to true
        UserDefaults.standard.set(true, forKey: "ClickToMinimizeEnabled")

        // Act
        // Initializing the view
        let _ = ContentView()

        // Assert
        // Verify that the value remains true
        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertTrue(isEnabled, "ContentView should respect existing true value in UserDefaults")
    }
}
