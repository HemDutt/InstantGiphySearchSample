//
//  GiffyServiceTest.swift
//  InstantGiphySearchTests
//
//  Created by Hem Sharma on 18/10/21.
//

import XCTest
@testable import InstantGiphySearch

class GiffyServiceTest: XCTestCase {

    func testParseRecommendationForStatusCode200() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let giffyNetworkService = GiffyNetworkService()
        let mockDataPath = Bundle(for: type(of: self)).path(forResource: "SearchSuggestion", ofType: "json")!
        let data = try Data.init(contentsOf: URL(fileURLWithPath: mockDataPath))

        let parserExpectation = expectation(description: "Check parsing for status code 200")
        giffyNetworkService.parseRecommendations(statusCode: 200, data: data) { recommendations, error in
            XCTAssertEqual(recommendations!.count, 10)
            XCTAssertNil(error)
            parserExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testParseRecommendationForError() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let giffyNetworkService = GiffyNetworkService()

        let parserExpectation = expectation(description: "Check parsing for status code 401, error condition")
        giffyNetworkService.parseRecommendations(statusCode: 401, data: nil) { recommendations, error in
            XCTAssertEqual(error, .authenticationError)
            XCTAssertNil(recommendations)
            parserExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
