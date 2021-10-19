//
//  SynchronisedArray.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 19/10/21.
//

import Foundation

public class SynchronizedArray<T> {
    private var array: [T] = []
    private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)

    public func append(newElement: T) {
        self.accessQueue.async(flags:.barrier) {
            self.array.append(newElement)
        }
    }

    public func append(newElements: [T]) {
        self.accessQueue.async(flags:.barrier) {
            self.array.append(contentsOf: newElements)
        }
    }

    public func removeAtIndex(index: Int) {
        self.accessQueue.async(flags:.barrier) {
            self.array.remove(at: index)
        }
    }

    public func removeAll() {
        self.accessQueue.async(flags:.barrier) {
            self.array.removeAll()
        }
    }

    public var count: Int {
        var count = 0
        self.accessQueue.sync {
            count = self.array.count
        }
        return count
    }

    public func first() -> T? {
        var element: T?
        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array[0]
            }
        }
        return element
    }

    public func allItems() -> [T]? {
        var elements: [T]?
        self.accessQueue.sync {
            elements = self.array
        }
        return elements
    }

    public subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags:.barrier) {
                self.array[index] = newValue
            }
        }
        get {
            var element: T!
            self.accessQueue.sync {
                element = self.array[index]
            }
            return element
        }
    }
}
