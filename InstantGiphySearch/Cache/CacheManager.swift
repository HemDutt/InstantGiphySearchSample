//
//  CacheManager.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

/// Provides a Singleton instance for SwiftyCache
protocol CacheManagerProtocol {
    var cache : SwiftyCache<String, Any> { get }
}

class CacheManager{
    static let shared = CacheManager()
    let cache = SwiftyCache<String, Any>()
    private init(){
        //Do nothing
    }
}
