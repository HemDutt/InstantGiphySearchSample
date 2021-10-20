//
//  SwiftyCacheTest.swift
//  InstantGiphySearchTests
//
//  Created by Hem Sharma on 18/10/21.
//

import XCTest
@testable import InstantGiphySearch

class SwiftyCacheTest: XCTestCase {

    func testLimitExceedForCache(){
        CacheManager.shared.cache.setCostLimit(limit: 100)
        let list = [GiphyRecommendationModel(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.shared.cache.insert(list, forKey: "Key", insertionCost:cost )
        let value = CacheManager.shared.cache["Key"]
        XCTAssertNil(value)
    }

    func testWithValidLimitForCache(){
        CacheManager.shared.cache.setCostLimit(limit: 200)
        let list = [GiphyRecommendationModel(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.shared.cache.insert(list, forKey: "Key", insertionCost:cost )
        let value = CacheManager.shared.cache["Key"] as! [GiphyRecommendationModel]
        XCTAssertEqual(value, [GiphyRecommendationModel(name: "ValidValue")])
    }

    func testCacheCleanup(){
        CacheManager.shared.cache.setCostLimit(limit: 300)
        let list = [GiphyRecommendationModel(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.shared.cache.insert(list, forKey: "Key", insertionCost:cost )
        let value = CacheManager.shared.cache["Key"] as! [GiphyRecommendationModel]
        XCTAssertEqual(value, [GiphyRecommendationModel(name: "ValidValue")])

        let newList = [GiphyRecommendationModel(name: "UpdatedValidValue")]
        let newCost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: newList)
        CacheManager.shared.cache.insert(newList, forKey: "Key1", insertionCost:newCost)
        let newValue = CacheManager.shared.cache["Key1"] as! [GiphyRecommendationModel]
        XCTAssertEqual(newValue, [GiphyRecommendationModel(name: "UpdatedValidValue")])

        let oldCachedValue = CacheManager.shared.cache["Key"]
        XCTAssertNil(oldCachedValue)
    }
}
