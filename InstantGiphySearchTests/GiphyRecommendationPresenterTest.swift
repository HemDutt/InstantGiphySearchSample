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
        func requestRecommendationsFor(searchedText: String, completionHandler: @escaping ([GiphyRecommendationModel]?, GiphyServiceError?) -> Void) {
            let remoteRecommendations = [GiphyRecommendationModel(name: "Tested1"), GiphyRecommendationModel(name: "Tested2"), GiphyRecommendationModel(name: "Tested3"), GiphyRecommendationModel(name: "Tested4"), GiphyRecommendationModel(name: "Tested5"), GiphyRecommendationModel(name: "Tested6")]
            completionHandler(remoteRecommendations,nil)
        }

        func cancelAllPendingRequests() {

        }
    }

    func testGetGiphyRecommendationsWithoutCache() {
        //Not setting expectation for cached data as the block should not be called if no cached data available
        let remoteDataExpectation = expectation(description: "Check Giphy recommendations from remote data")

        let presenter = GiphyRecommendationPresenter(networkService: MockGiphyRecommendationService())
        presenter.getGiphyRecommendationsFor(searchedText: "SomeText") { cachedResults, indeces in
            XCTAssertTrue(cachedResults.count == 0)
        } remoteResults: { remoteResults, indeces in
            XCTAssertTrue(remoteResults.count == 6)
            remoteDataExpectation.fulfill()
        } error: { err in
            XCTAssert(true)
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testGetGiphyRecommendationsWithCache() {
        //Not setting expectation for cached data as the block should not be called if no cached data available
        let list = [GiphyRecommendationModel(name: "CachedValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.shared.cache.insert(list, forKey: "Test", insertionCost:cost )

        let remoteDataExpectation = expectation(description: "Check Giphy recommendations from remote data")
        let cachedDataExpectation = expectation(description: "Check Giphy recommendations from cached data")

        let presenter = GiphyRecommendationPresenter(networkService: MockGiphyRecommendationService())
        presenter.getGiphyRecommendationsFor(searchedText: "Test") { cachedResults, indeces in
            XCTAssertTrue(cachedResults.count == 1)
            XCTAssertEqual(cachedResults, [GiphyRecommendationModel(name: "CachedValue")])
            cachedDataExpectation.fulfill()
        } remoteResults: { remoteResults, indeces in
            XCTAssertTrue(remoteResults.count == 6)
            remoteDataExpectation.fulfill()
        } error: { err in
            XCTAssert(true)
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
