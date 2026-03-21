import XCTest
import SwiftUI
@testable import Click2Minimize

final class ContentViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UserDefaults.standard.removeObject(forKey: "ClickToMinimizeEnabled")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UserDefaults.standard.removeObject(forKey: "ClickToMinimizeEnabled")
    }

    func testContentViewDefaultState() throws {
        // Given that UserDefaults is empty, initializing ContentView should set ClickToMinimizeEnabled to true
        let _ = ContentView()

        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertTrue(isEnabled, "ClickToMinimizeEnabled should default to true")
    }

    func testContentViewExistingStateTrue() throws {
        // Given that UserDefaults is already set to true
        UserDefaults.standard.set(true, forKey: "ClickToMinimizeEnabled")

        let _ = ContentView()

        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertTrue(isEnabled, "ClickToMinimizeEnabled should remain true if previously set")
    }

    func testContentViewExistingStateFalse() throws {
        // Given that UserDefaults is already set to false
        UserDefaults.standard.set(false, forKey: "ClickToMinimizeEnabled")

        let _ = ContentView()

        let isEnabled = UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
        XCTAssertFalse(isEnabled, "ClickToMinimizeEnabled should remain false if previously set")
    }
}
