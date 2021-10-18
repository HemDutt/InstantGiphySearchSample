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
        CacheManager.cache.setCostLimit(limit: 1)
        CacheManager.cache["Key"] = "ValidValue"
        let value = CacheManager.cache["Key"]
        XCTAssertNil(value)
    }

    func testWithValidLimitForCache(){
        CacheManager.cache.setCostLimit(limit: 20)
        CacheManager.cache["Key"] = "ValidValue"
        let value = CacheManager.cache["Key"] as? String
        XCTAssertEqual(value, "ValidValue")
    }
}
