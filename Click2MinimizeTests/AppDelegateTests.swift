import XCTest
@testable import Click2Minimize

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
    }
}

final class AppDelegateTests: XCTestCase {

    var appDelegate: AppDelegate!
    var session: URLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        appDelegate = AppDelegate()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
    }

    override func tearDownWithError() throws {
        appDelegate = nil
        session = nil
        MockURLProtocol.requestHandler = nil
        try super.tearDownWithError()
    }

    func testFetchLatestDMG_JSONParsingError() throws {
        // Arrange
        let expectation = self.expectation(description: "Fetch Latest DMG")

        // Mock invalid JSON response (missing "assets" key)
        let jsonString = """
        {
            "tag_name": "v1.2.0"
        }
        """
        let responseData = jsonString.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }

        // Override urlOpener to fulfill expectation and avoid actual opening
        appDelegate.urlOpener = { url in
            XCTAssertEqual(url.absoluteString, "https://github.com/hatimhtm/Click2Minimize/releases")
            expectation.fulfill()
        }

        // Act
        appDelegate.fetchLatestDMG(releaseInfo: AppDelegate.Release(tag_name: "v1.2.0"), session: session)

        // Assert
        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(appDelegate.didOpenBrowserForManualUpgrade)
    }
}
