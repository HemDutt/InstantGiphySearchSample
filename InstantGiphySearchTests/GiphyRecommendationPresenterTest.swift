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

    func testGetGiphyRecommendations() {
        let cachedDataExpectation = expectation(description: "Check Giphy recommendations from cached data")
        let remoteDataExpectation = expectation(description: "Check Giphy recommendations from remote data")

        let presenter = GiphyRecommendationPresenter()
        presenter.getGiphyRecommendationsFor(searchedText: "Test", giphyNetworkService: MockGiphyRecommendationService()) { cachedResults in
            XCTAssertTrue(cachedResults.count == 0)
            cachedDataExpectation.fulfill()
        } remoteResults: { remoteResults in
            XCTAssertTrue(remoteResults.count == 6)
            remoteDataExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testGetListOfNewItemsOnly() {
        let cachedRecommendations = [GiphyStruct(name: "Tested1"), GiphyStruct(name: "Tested2")]
        let remoteRecommendations = [GiphyStruct(name: "Tested1"), GiphyStruct(name: "Tested2"), GiphyStruct(name: "Tested3")]

        let presenter = GiphyRecommendationPresenter()
        let mergedRecommendations = presenter.filterListForNewItemsOnly(oldList: cachedRecommendations, newList: remoteRecommendations)

        XCTAssertTrue(mergedRecommendations.count == 1)
        XCTAssertEqual(mergedRecommendations[0].name, "Tested3")
    }

    func testGetnewIndeces() {
        let presenter = GiphyRecommendationPresenter()
        let indeces = presenter.getnewIndecesAfter(initialCount: 2, newElementsCount: 1)
        XCTAssertEqual(indeces[0].row, 2)
        XCTAssertEqual(indeces[0].section, 0)
    }

}
