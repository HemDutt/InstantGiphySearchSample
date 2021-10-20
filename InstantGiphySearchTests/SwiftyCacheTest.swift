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
        CacheManager.cache.setCostLimit(limit: 100)
        let list = [GiphyStruct(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.cache.insert(list, forKey: "Key", insertionCost:cost )
        let value = CacheManager.cache["Key"]
        XCTAssertNil(value)
    }

    func testWithValidLimitForCache(){
        CacheManager.cache.setCostLimit(limit: 200)
        let list = [GiphyStruct(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.cache.insert(list, forKey: "Key", insertionCost:cost )
        let value = CacheManager.cache["Key"] as! [GiphyStruct]
        XCTAssertEqual(value, [GiphyStruct(name: "ValidValue")])
    }

    func testCacheCleanup(){
        CacheManager.cache.setCostLimit(limit: 300)
        let list = [GiphyStruct(name: "ValidValue")]
        let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: list)
        CacheManager.cache.insert(list, forKey: "Key", insertionCost:cost )
        let value = CacheManager.cache["Key"] as! [GiphyStruct]
        XCTAssertEqual(value, [GiphyStruct(name: "ValidValue")])

        let newList = [GiphyStruct(name: "UpdatedValidValue")]
        let newCost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: newList)
        CacheManager.cache.insert(newList, forKey: "Key1", insertionCost:newCost)
        let newValue = CacheManager.cache["Key1"] as! [GiphyStruct]
        XCTAssertEqual(newValue, [GiphyStruct(name: "UpdatedValidValue")])

        let oldCachedValue = CacheManager.cache["Key"]
        XCTAssertNil(oldCachedValue)
    }
}
