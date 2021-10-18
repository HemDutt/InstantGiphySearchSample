//
//  CacheManager.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

/// Provides a Singleton instance for SwiftyCache
class CacheManager{
    static let cache = SwiftyCache<String, Any>()
    private init(){
        //Do nothing
    }
}
