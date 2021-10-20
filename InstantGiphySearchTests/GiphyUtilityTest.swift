//
//  GiphyUtilityTest.swift
//  InstantGiphySearchTests
//
//  Created by Hem Sharma on 20/10/21.
//

import XCTest
@testable import InstantGiphySearch

class GiphyUtilityTest: XCTestCase {

    func testCostOfInsertion(){
        let list = [GiphyRecommendationModel(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        XCTAssertEqual(cost, 160)
    }

    func testGetListOfNewItemsOnly() {
        let cachedRecommendations = [GiphyRecommendationModel(name: "Tested1"), GiphyRecommendationModel(name: "Tested2")]
        let remoteRecommendations = [GiphyRecommendationModel(name: "Tested1"), GiphyRecommendationModel(name: "Tested2"), GiphyRecommendationModel(name: "Tested3")]

        let mergedRecommendations = GiphyUtility.filterListForNewItemsOnly(oldList: cachedRecommendations, newList: remoteRecommendations)

        XCTAssertTrue(mergedRecommendations.count == 1)
        XCTAssertEqual(mergedRecommendations[0].name, "Tested3")
    }

    func testGetnewIndeces() {
        let indeces = GiphyUtility.getnewIndecesAfter(initialCount: 2, newElementsCount: 1)
        XCTAssertEqual(indeces[0].row, 2)
        XCTAssertEqual(indeces[0].section, 0)
    }
}
