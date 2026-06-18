import XCTest
@testable import Click2Minimize

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!

    override func setUpWithError() throws {
        super.setUp()
        appDelegate = AppDelegate()
    }

    override func tearDownWithError() throws {
        appDelegate = nil
        super.tearDown()
    }

    func testAppDictSetup() throws {
        appDelegate.setupAppDict()

        XCTAssertFalse(appDelegate.appDict.isEmpty, "appDict should not be empty after setup")
        XCTAssertNotNil(appDelegate.appDict["Finder"], "appDict should contain 'Finder'")
        XCTAssertEqual(appDelegate.appDict["Finder"], "com.apple.finder")
    }

    func testIsNewerVersion() throws {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.1", currentVersion: "1.0.0"))
        XCTAssertTrue(appDelegate.isNewerVersion("1.1", currentVersion: "1.0.5"))
        XCTAssertTrue(appDelegate.isNewerVersion("2.0.0", currentVersion: "1.9.9"))

        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.0"))

        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.1"))
        XCTAssertFalse(appDelegate.isNewerVersion("0.9.9", currentVersion: "1.0.0"))

        XCTAssertTrue(appDelegate.isNewerVersion("1.0.0.1", currentVersion: "1.0.0"))
        XCTAssertFalse(appDelegate.isNewerVersion("1.0", currentVersion: "1.0.0"))
    }
}
