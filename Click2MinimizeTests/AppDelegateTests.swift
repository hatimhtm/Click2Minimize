import XCTest
@testable import Click2Minimize

class AppDelegateTests: XCTestCase {

    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }

    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }

    func testIsNewerVersion_NewerMajor() {
        XCTAssertTrue(appDelegate.isNewerVersion("2.0.0", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_NewerMinor() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.1.0", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_NewerPatch() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.1", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_OlderMajor() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "2.0.0"))
    }

    func testIsNewerVersion_OlderMinor() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.1.0"))
    }

    func testIsNewerVersion_OlderPatch() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.1"))
    }

    func testIsNewerVersion_SameVersion() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0.0", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_MissingPatchNew() {
        XCTAssertFalse(appDelegate.isNewerVersion("1.0", currentVersion: "1.0.1"))
    }

    func testIsNewerVersion_MissingPatchCurrent() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.1", currentVersion: "1.0"))
    }

    func testIsNewerVersion_MissingMinorAndPatchNew() {
        XCTAssertFalse(appDelegate.isNewerVersion("1", currentVersion: "1.1.0"))
    }

    func testIsNewerVersion_MissingMinorAndPatchCurrent() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.1.0", currentVersion: "1"))
    }

    func testIsNewerVersion_EmptyStrings() {
        XCTAssertFalse(appDelegate.isNewerVersion("", currentVersion: ""))
    }

    func testIsNewerVersion_InvalidStrings() {
        XCTAssertFalse(appDelegate.isNewerVersion("a.b.c", currentVersion: "x.y.z"))
    }

    func testIsNewerVersion_InvalidNewVersionValidCurrent() {
        XCTAssertFalse(appDelegate.isNewerVersion("a.b.c", currentVersion: "1.0.0"))
    }

    func testIsNewerVersion_ValidNewVersionInvalidCurrent() {
        XCTAssertTrue(appDelegate.isNewerVersion("1.0.0", currentVersion: "a.b.c"))
    }
}
