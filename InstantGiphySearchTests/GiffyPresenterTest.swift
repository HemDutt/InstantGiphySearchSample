//
//  GiffyPresenterTest.swift
//  InstantGiphySearchTests
//
//  Created by Hem Sharma on 18/10/21.
//

import XCTest
@testable import InstantGiphySearch

class GiffyPresenterTest: XCTestCase {

    class MockGiffyNetworkService : GiffyNetworkServiceProtocol{
        func requestRecommendationsFor(searchText: String, completionHandler: @escaping ([GiffyStruct]?, GiffyServiceError?) -> Void) {
            let remoteRecommendations = [GiffyStruct(name: "Tested1"), GiffyStruct(name: "Tested2"), GiffyStruct(name: "Tested3"), GiffyStruct(name: "Tested4"), GiffyStruct(name: "Tested5"), GiffyStruct(name: "Tested6")]
            completionHandler(remoteRecommendations,nil)
        }
    }

    func testGetGiffyRecommendations() throws {
        let cachedDataExpectation = expectation(description: "Check Giffy recommendations from cached data")
        let remoteDataExpectation = expectation(description: "Check Giffy recommendations from remote data")

        let presenter = GiffyRecommendationPresenter()
        presenter.getGiffyRecommendationsFor(searchText: "Test", giffyNetworkService: MockGiffyNetworkService()) { cachedResults in
            XCTAssertTrue(cachedResults.count == 0)
            cachedDataExpectation.fulfill()
        } remoteResults: { remoteResults in
            XCTAssertTrue(remoteResults.count == 6)
            remoteDataExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testGetListOfNewItemsOnly() throws {
        let cachedRecommendations = [GiffyStruct(name: "Tested1"), GiffyStruct(name: "Tested2")]
        let remoteRecommendations = [GiffyStruct(name: "Tested1"), GiffyStruct(name: "Tested2"), GiffyStruct(name: "Tested3")]

        let presenter = GiffyRecommendationPresenter()
        let mergedRecommendations = presenter.filterListForNewItemsOnly(oldList: cachedRecommendations, newList: remoteRecommendations)

        XCTAssertTrue(mergedRecommendations.count == 1)
        XCTAssertEqual(mergedRecommendations[0].name, "Tested3")
    }

    func testGetnewIndeces() throws {
        let presenter = GiffyRecommendationPresenter()
        let indeces = presenter.getnewIndecesAfter(initialCount: 2, newElementsCount: 1)
        XCTAssertEqual(indeces[0].row, 2)
        XCTAssertEqual(indeces[0].section, 0)
    }

}
