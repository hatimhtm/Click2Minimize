import XCTest
@testable import Click2Minimize

class MockFileManager: FileManagerProtocol {
    var shouldThrowOnCopy = false

    enum MockError: Error {
        case copyFailed
    }

    func fileExists(atPath path: String) -> Bool {
        return false
    }

    func removeItem(at URL: URL) throws {
        // Do nothing
    }

    func copyItem(at srcURL: URL, to dstURL: URL) throws {
        if shouldThrowOnCopy {
            throw MockError.copyFailed
        }
    }
}

class AppDelegateTests: XCTestCase {

    func testInstallAppFromMountedVolumeThrowsError_OpensBrowser() {
        // Arrange
        let appDelegate = AppDelegate()

        let mockFileManager = MockFileManager()
        mockFileManager.shouldThrowOnCopy = true

        appDelegate.fileManager = mockFileManager
        appDelegate.disableSystemCallsForTesting = true
        appDelegate.openedBrowserForManualUpgrade = false

        // Act
        appDelegate.installApp(from: "/test/volume")

        // Assert
        XCTAssertTrue(appDelegate.openedBrowserForManualUpgrade, "openBrowserForManualUpgrade should be called when fileManager.copyItem throws an error")
    }
}
