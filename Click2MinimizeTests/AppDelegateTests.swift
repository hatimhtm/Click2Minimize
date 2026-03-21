import XCTest
@testable import Click2Minimize

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?
    static var requestURLs: [URL] = []

    static func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
        requestURLs.removeAll()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let url = request.url {
            MockURLProtocol.requestURLs.append(url)
        }

        if let error = MockURLProtocol.mockError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.mockResponse {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.mockData {
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()

        // Setup mock URLSession
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: configuration)

        appDelegate.urlSession = mockSession
        MockURLProtocol.reset()
    }

    override func tearDown() {
        appDelegate = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testFetchLatestDMG_InvalidJSON() {
        let invalidJSONString = "{ invalid_json: "
        MockURLProtocol.mockData = invalidJSONString.data(using: .utf8)

        let releaseInfo = AppDelegate.Release(tag_name: "1.0.0")

        let expectation = XCTestExpectation(description: "Wait for fetch task to complete")
        appDelegate.fetchLatestDMG(releaseInfo: releaseInfo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Verify only 1 request was made (to the releases API), and no DMG download was triggered.
            XCTAssertEqual(MockURLProtocol.requestURLs.count, 1, "Expected exactly 1 request for the release API.")
            if let firstURL = MockURLProtocol.requestURLs.first {
                XCTAssertTrue(firstURL.absoluteString.contains("releases/latest"), "Expected API URL.")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchLatestDMG_ValidJSON_MissingAssets() {
        let validJSONString = "{\"not_assets\": []}"
        MockURLProtocol.mockData = validJSONString.data(using: .utf8)

        let releaseInfo = AppDelegate.Release(tag_name: "1.0.0")

        let expectation = XCTestExpectation(description: "Wait for fetch task to complete")
        appDelegate.fetchLatestDMG(releaseInfo: releaseInfo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Verify only 1 request was made (to the releases API), and no DMG download was triggered.
            XCTAssertEqual(MockURLProtocol.requestURLs.count, 1, "Expected exactly 1 request for the release API.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchLatestDMG_ValidJSON_NoDMG() {
        let validJSONString = """
        {
            "assets": [
                {
                    "browser_download_url": "https://example.com/app.zip",
                    "name": "app.zip"
                }
            ]
        }
        """
        MockURLProtocol.mockData = validJSONString.data(using: .utf8)

        let releaseInfo = AppDelegate.Release(tag_name: "1.0.0")

        let expectation = XCTestExpectation(description: "Wait for fetch task to complete")
        appDelegate.fetchLatestDMG(releaseInfo: releaseInfo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Verify only 1 request was made (to the releases API), and no DMG download was triggered.
            XCTAssertEqual(MockURLProtocol.requestURLs.count, 1, "Expected exactly 1 request for the release API.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchLatestDMG_HappyPath() {
        let validJSONString = """
        {
            "assets": [
                {
                    "browser_download_url": "https://example.com/app.dmg",
                    "name": "app.dmg"
                }
            ]
        }
        """
        MockURLProtocol.mockData = validJSONString.data(using: .utf8)

        let releaseInfo = AppDelegate.Release(tag_name: "1.0.0")

        let expectation = XCTestExpectation(description: "Wait for fetch task to complete")
        appDelegate.fetchLatestDMG(releaseInfo: releaseInfo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Verify 2 requests were made (API fetch + DMG download)
            XCTAssertEqual(MockURLProtocol.requestURLs.count, 2, "Expected 2 requests: one for API, one for DMG download.")

            if MockURLProtocol.requestURLs.count == 2 {
                XCTAssertTrue(MockURLProtocol.requestURLs[0].absoluteString.contains("releases/latest"), "First request should be the API.")
                XCTAssertTrue(MockURLProtocol.requestURLs[1].absoluteString.contains("app.dmg"), "Second request should be the DMG download.")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
