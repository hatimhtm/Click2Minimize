import XCTest
@testable import Click2Minimize

class MockURLSession: URLSessionProtocol {
    var error: Error?
    var data: Data?

    func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, nil, self.error)
        }
    }

    func downloadTask(with url: URL, completionHandler: @escaping @Sendable (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        return MockURLSessionDownloadTask {
            completionHandler(nil, nil, self.error)
        }
    }
}

class AppDelegateTests: XCTestCase {

    var appDelegate: AppDelegate!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
        mockSession = MockURLSession()
        appDelegate.urlSession = mockSession
    }

    override func tearDown() {
        appDelegate = nil
        mockSession = nil
        super.tearDown()
    }

    func testFetchLatestDMG_ErrorPath() {
        // Arrange
        let expectedError = NSError(domain: "TestError", code: 123, userInfo: nil)
        mockSession.error = expectedError

        let release = AppDelegate.Release(tag_name: "v1.0.0")

        // Act
        appDelegate.fetchLatestDMG(releaseInfo: release)

        // Assert
        XCTAssertNotNil(appDelegate.lastError)
        if let actualError = appDelegate.lastError as NSError? {
            XCTAssertEqual(actualError.domain, expectedError.domain)
            XCTAssertEqual(actualError.code, expectedError.code)
        }
    }
}
