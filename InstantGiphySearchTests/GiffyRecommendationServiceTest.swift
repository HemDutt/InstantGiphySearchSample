//
//  GiffyRecommendationServiceTest.swift
//  InstantGiphySearchTests
//
//  Created by Hem Sharma on 18/10/21.
//

import XCTest
@testable import InstantGiphySearch

class GiffyRecommendationServiceTest: XCTestCase {

    var giffyNetworkService: GiffyRecommendationService!
    var expectation: XCTestExpectation!
    let baseURL = URL(string: "https://api.giphy.com/v1/tags/related/")!

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)

        giffyNetworkService = GiffyRecommendationService(session: urlSession)
        expectation = expectation(description: "Expectation")
    }

    func testParseRecommendationForStatusCode200() throws {
        let mockDataPath = Bundle(for: type(of: self)).path(forResource: "SearchSuggestion", ofType: "json")!
        let data = try Data.init(contentsOf: URL(fileURLWithPath: mockDataPath))

        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url.absoluteString.hasPrefix(self.baseURL.absoluteString) else {
                throw NSError(domain: "0", code: 0, userInfo: nil)
              }

              let response = HTTPURLResponse(url: self.baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
              return (response, data)
        }

        giffyNetworkService.requestRecommendationsFor(searchedText: "Robot") { response, error in
            XCTAssertEqual(response?.count, 10)
            XCTAssertNil(error)
            self.expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testParseRecommendationForError() throws {
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url.absoluteString.hasPrefix(self.baseURL.absoluteString) else {
                throw NSError(domain: "0", code: 0, userInfo: nil)
              }

              let response = HTTPURLResponse(url: self.baseURL, statusCode: 401, httpVersion: nil, headerFields: nil)!
              return (response, nil)
        }

        giffyNetworkService.requestRecommendationsFor(searchedText: "Robot") { response, error in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
