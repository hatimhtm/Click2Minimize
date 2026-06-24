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

    func testSetupAppDict() {
        // Given
        XCTAssertTrue(appDelegate.appDict.isEmpty, "appDict should be empty initially")

        // When
        appDelegate.setupAppDict()

        // Then
        XCTAssertEqual(appDelegate.appDict.count, 2, "appDict should contain exactly 2 items")
        XCTAssertEqual(appDelegate.appDict["Visual Studio Code"], "Code", "Value for 'Visual Studio Code' should be 'Code'")
        XCTAssertEqual(appDelegate.appDict["Rosetta Stone Learn Languages"], "Rosetta Stone", "Value for 'Rosetta Stone Learn Languages' should be 'Rosetta Stone'")
    }
}
