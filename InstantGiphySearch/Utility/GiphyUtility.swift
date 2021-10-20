//
//  GiphyUtility.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 20/10/21.
//

import Foundation

struct GiphyUtility{

    /// Calculate cost of insertion in Cache for an array of GiphyStruct
    /// - Parameter list: An array of GiphyStruct
    /// - Returns: Cost of insertion in cache
    static func getCostForInsertingGiphyRecommendations(list: [GiphyRecommendationModel]) -> Int{
        var costOfInsertion = 0
        for item in list {
            costOfInsertion += MemoryLayout.size(ofValue: item.name) * item.name.count
        }
        return costOfInsertion
    }

    /// Given 2 arrays, this function returns values from newList which are not present in oldList
    /// - Parameters:
    ///   - oldList: Old list containg objects of type GiphyStruct
    ///   - newList: New list containg objects of type GiphyStruct
    static func filterListForNewItemsOnly(oldList : [GiphyRecommendationModel], newList : [GiphyRecommendationModel]) -> [GiphyRecommendationModel]{
        guard !oldList.isEmpty else {
            return newList
        }
        return Array(Set(newList).subtracting(oldList))
    }

    /// Return a list of indexes to be added at the bottom of table view while user is browsing through old recommendations
    /// - Parameters:
    ///   - initialCount: Count of elements currently showing on table view in ViewController
    ///   - newElementsCount: Count of new elements which needs to be added on table view in ViewController
    static func getnewIndecesAfter(initialCount: Int, newElementsCount: Int)->[IndexPath]{
        var indeces : [IndexPath] = []
        let lastIndex = newElementsCount+initialCount
        for index in initialCount..<lastIndex{
            indeces.append(IndexPath(row: index, section: 0))
        }
        return indeces
    }

    /// Creates a timestamp
    /// - Returns: timestamp
    static func getTimeStammp() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        return formatter.string(from: date)
    }
}
