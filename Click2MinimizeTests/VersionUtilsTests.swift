import XCTest
@testable import Click2Minimize

final class VersionUtilsTests: XCTestCase {

    func testIsNewerVersion() {
        // Newer versions
        XCTAssertTrue(VersionUtils.isNewerVersion("1.0.1", currentVersion: "1.0.0"))
        XCTAssertTrue(VersionUtils.isNewerVersion("1.1.0", currentVersion: "1.0.0"))
        XCTAssertTrue(VersionUtils.isNewerVersion("2.0.0", currentVersion: "1.0.0"))
        XCTAssertTrue(VersionUtils.isNewerVersion("1.0.0.1", currentVersion: "1.0.0"))

        // Older versions
        XCTAssertFalse(VersionUtils.isNewerVersion("1.0.0", currentVersion: "1.0.1"))
        XCTAssertFalse(VersionUtils.isNewerVersion("1.0.0", currentVersion: "1.1.0"))
        XCTAssertFalse(VersionUtils.isNewerVersion("1.0.0", currentVersion: "2.0.0"))
        XCTAssertFalse(VersionUtils.isNewerVersion("1.0.0", currentVersion: "1.0.0.1"))

        // Equal versions
        XCTAssertFalse(VersionUtils.isNewerVersion("1.0.0", currentVersion: "1.0.0"))
        XCTAssertFalse(VersionUtils.isNewerVersion("2.1.3", currentVersion: "2.1.3"))

        // Edge cases
        XCTAssertFalse(VersionUtils.isNewerVersion("1.0", currentVersion: "1.0.0"))
        XCTAssertTrue(VersionUtils.isNewerVersion("1.0.0", currentVersion: "1.0"))
    }
}
