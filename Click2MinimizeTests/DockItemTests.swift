import XCTest
@testable import Click2Minimize

class DockItemTests: XCTestCase {

    func testDockItemInitialization() {
        // Arrange
        let expectedRect = NSRect(x: 10, y: 20, width: 30, height: 40)
        let expectedAppID = "com.apple.Safari"

        // Act
        let dockItem = AppDelegate.DockItem(rect: expectedRect, appID: expectedAppID)

        // Assert
        XCTAssertEqual(dockItem.rect, expectedRect, "The rect should be correctly initialized.")
        XCTAssertEqual(dockItem.appID, expectedAppID, "The appID should be correctly initialized.")
    }
}
