import XCTest
@testable import Click2Minimize

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()

        // Reset UserDefaults for isolated testing
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }

    override func tearDown() {
        appDelegate = nil
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        super.tearDown()
    }

    func testUpdateClickToHideState_EnablesState() {
        // Arrange
        let notification = Notification(name: NSNotification.Name("ClickToHideStateChanged"), object: true)

        // Act
        appDelegate.updateClickToHideState(notification)

        // Assert
        XCTAssertTrue(appDelegate.isClickToMinimizeEnabled)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled"))
    }

    func testUpdateClickToHideState_DisablesState() {
        // Arrange
        // Set initial state to true to ensure it actually changes to false
        appDelegate.isClickToMinimizeEnabled = true
        UserDefaults.standard.set(true, forKey: "ClickToMinimizeEnabled")

        let notification = Notification(name: NSNotification.Name("ClickToHideStateChanged"), object: false)

        // Act
        appDelegate.updateClickToHideState(notification)

        // Assert
        XCTAssertFalse(appDelegate.isClickToMinimizeEnabled)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled"))
    }

    func testUpdateClickToHideState_InvalidObject() {
        // Arrange
        appDelegate.isClickToMinimizeEnabled = true
        UserDefaults.standard.set(true, forKey: "ClickToMinimizeEnabled")

        let notification = Notification(name: NSNotification.Name("ClickToHideStateChanged"), object: "Not a boolean")

        // Act
        appDelegate.updateClickToHideState(notification)

        // Assert - state should remain unchanged
        XCTAssertTrue(appDelegate.isClickToMinimizeEnabled)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled"))
    }
}
