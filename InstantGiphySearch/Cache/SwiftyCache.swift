//
//  SwiftyCache.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

final class SwiftyCache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, CacheObject>()
    func insert(_ value: Value, forKey key: Key) {
        let object = CacheObject(value: value)
        let wrappedKey = WrappedKey(key)
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
