import XCTest
@testable import Click2Minimize

final class AppDelegateTests: XCTestCase {

    func testSetupAppDict() {
        let appDelegate = AppDelegate()
        appDelegate.setupAppDict()

        XCTAssertEqual(appDelegate.appDict["Visual Studio Code"], "Code")
        XCTAssertEqual(appDelegate.appDict["Rosetta Stone Learn Languages"], "Rosetta Stone")
        XCTAssertNil(appDelegate.appDict["Nonexistent App"])
    }

    func testDockItemInitialization() {
        let rect = NSRect(x: 10, y: 20, width: 30, height: 40)
        let appID = "TestApp"

        let dockItem = AppDelegate.DockItem(rect: rect, appID: appID)

        XCTAssertEqual(dockItem.rect, rect)
        XCTAssertEqual(dockItem.appID, appID)
    }
}
