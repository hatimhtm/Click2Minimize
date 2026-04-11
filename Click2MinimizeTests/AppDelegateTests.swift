import XCTest
@testable import Click2Minimize

final class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }

    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }

    func testIsNewerVersion_MajorVersionNewer() {
        XCTAssertTrue(appDelegate.isNewerVersion("2.0.0", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_MajorVersionOlder() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "2.0.0"))
    }

    func testIsNewerVersion_MinorVersionNewer() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.1.0", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_MinorVersionOlder() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.1.0"))
    }

    func testIsNewerVersion_PatchVersionNewer() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.1", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_PatchVersionOlder() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.1"))
    }

    func testIsNewerVersion_SameVersion() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_MoreComponentsNewer() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.0.1", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_FewerComponentsOlder() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.0.1"))
    }

    func testIsNewerVersion_EmptyStrings() {
        XCTAssertFalse(appDelegate.isNewerVersion("", currentVersion: ""))
    }

    func testIsNewerVersion_EmptyNewVersion() {
        XCTAssertFalse(appDelegate.isNewerVersion("", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_EmptyCurrentVersion() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.0", currentVersion: ""))
    }

    func testIsNewerVersion_InvalidCharacters() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.a.0", currentVersion: "1.b.0")) // Falls back to 0.0.0 for both
        XCTAssertTrue(appDelegate.isNewerVersion("1.1.0", currentVersion: "1.a.0")) // 1.1.0 vs 1.0.0
    }
}
