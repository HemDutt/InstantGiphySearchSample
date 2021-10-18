//
//  SwiftyCache.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

/// Reference : https://developer.apple.com/documentation/foundation/nscache
/// NSCache is a mutable collection you use to temporarily store transient key-value pairs that are subject to eviction when resources are low.
/// The NSCache class incorporates various auto-eviction policies, which ensure that a cache doesn’t use too much of the system’s memory. If memory is needed by other applications, these policies remove some items from the cache, minimizing its memory footprint.
/// We can add, remove, and query items in the cache from different threads without having to lock the cache explicitely in our code.
/// SwiftyCache is a wrapper class over NSCache to enable us store structs and other value types and lets us use any Hashable key type  without rewriting all of the underlying logic that powers NSCache.
/// SwiftyCache is generic over any Hashable key type, and any value type.
final class SwiftyCache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, CacheObject>()
    func insert(_ value: Value, forKey key: Key) {
        let object = CacheObject(value: value)
        let wrappedKey = WrappedKey(key)
        // We would want the cache to not grow beyond a specified size in memory.
        // Cost for every insertion is calculated.
        let costOfInsertion = MemoryLayout.size(ofValue: object) + MemoryLayout.size(ofValue: wrappedKey)
        wrapped.setObject(object, forKey: wrappedKey, cost:costOfInsertion)
    }

    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    func setCostLimit(limit: Int) {
        wrapped.totalCostLimit = limit
    }
}

private extension SwiftyCache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension SwiftyCache {
    final class CacheObject {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}

/// Since SwiftyCache is essentially just a specialized key-value store, it’s an ideal use case for subscripting.
/// It is possible to both retrieve and insert values in SwiftyCache using subscripts
extension SwiftyCache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}
