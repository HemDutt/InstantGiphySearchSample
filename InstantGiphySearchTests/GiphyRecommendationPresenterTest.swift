//
//  GiphyRecommendationPresenterTest.swift
//  InstantGiphySearchTests
//
//  Created by Hem Sharma on 18/10/21.
//

import XCTest
@testable import InstantGiphySearch

class GiphyRecommendationPresenterTest: XCTestCase {

    class MockGiphyRecommendationService : GiphyRecommendationServiceProtocol{
        func requestRecommendationsFor(searchedText: String, completionHandler: @escaping ([GiphyStruct]?, GiphyServiceError?) -> Void) {
            let remoteRecommendations = [GiphyStruct(name: "Tested1"), GiphyStruct(name: "Tested2"), GiphyStruct(name: "Tested3"), GiphyStruct(name: "Tested4"), GiphyStruct(name: "Tested5"), GiphyStruct(name: "Tested6")]
            completionHandler(remoteRecommendations,nil)
        }
    }

    func testGetGiphyRecommendationsWithoutCache() {
        //Not setting expectation for cached data as the block should not be called if no cached data available
        let remoteDataExpectation = expectation(description: "Check Giphy recommendations from remote data")

        let presenter = GiphyRecommendationPresenter()
        presenter.getGiphyRecommendationsFor(searchedText: "SomeText", giphyNetworkService: MockGiphyRecommendationService()) { cachedResults, indeces in
            XCTAssertTrue(cachedResults.count == 0)
        } remoteResults: { remoteResults, indeces in
            XCTAssertTrue(remoteResults.count == 6)
            remoteDataExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testGetGiphyRecommendationsWithCache() {
        //Not setting expectation for cached data as the block should not be called if no cached data available
        let list = [GiphyStruct(name: "CachedValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.cache.insert(list, forKey: "Test", insertionCost:cost )

        let remoteDataExpectation = expectation(description: "Check Giphy recommendations from remote data")
        let cachedDataExpectation = expectation(description: "Check Giphy recommendations from cached data")

        let presenter = GiphyRecommendationPresenter()
        presenter.getGiphyRecommendationsFor(searchedText: "Test", giphyNetworkService: MockGiphyRecommendationService()) { cachedResults, indeces in
            XCTAssertTrue(cachedResults.count == 1)
            XCTAssertEqual(cachedResults, [GiphyStruct(name: "CachedValue")])
            cachedDataExpectation.fulfill()
        } remoteResults: { remoteResults, indeces in
            XCTAssertTrue(remoteResults.count == 6)
            remoteDataExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
