import XCTest
import SwiftUI
@testable import Click2Minimize

class ContentViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset UserDefaults before each test to ensure a clean state
        UserDefaults.standard.removeObject(forKey: "ClickToMinimizeEnabled")
    }

    func testContentViewInitializationSetsDefaultUserDefault() {
        // Assert that the UserDefault is initially nil
        XCTAssertNil(UserDefaults.standard.object(forKey: "ClickToMinimizeEnabled"))

        // Initialize the view, which should trigger the @State initialization
        let view = ContentView()

        // Use a Mirror to force initialization of the @State if needed,
        // though just creating the struct in SwiftUI might not be enough.
        // Actually, just creating `ContentView()` runs the default value closure.
        let _ = view

        // Assert that the UserDefault was set to true
        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertTrue(isEnabled, "ContentView should set ClickToMinimizeEnabled to true by default")
    }

    func testContentViewRespectsExistingUserDefault() {
        // Set the UserDefault to false before initialization
        UserDefaults.standard.set(false, forKey: "ClickToMinimizeEnabled")

        // Initialize the view
        let view = ContentView()
        let _ = view

        // Assert that the UserDefault remains false
        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertFalse(isEnabled, "ContentView should respect existing ClickToMinimizeEnabled value")
    }

}
