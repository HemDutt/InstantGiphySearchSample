//
//  GiffyInterfaces.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

/// Enum for possible errors during Giffy service calls
enum GiffyServiceError
{
    case authenticationError
    case noInternet
    case timeOut
    case badResponseData
    case badRequest
    case emptyResponseData
    case unknownError
}

struct SearchSuggestions : Decodable {
    let data : [GiffyStruct]
}

/// Structure to hold parsed values of recommendations
struct GiffyStruct : Hashable,Decodable {
    let name : String
}

/// GiffyRecommendationPresenterProtocol  declares functions for Giffy recommendation presenter
protocol GiffyRecommendationPresenterProtocol{

    /// Fetch Giffy recommendations from local cache and remote server for the View Controller
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - giffyNetworkService: A service object to perform the remote fetch
    ///   - cachedResults: Recommendation list fetched from local cache
    ///   - remoteResults: Recommendation list fetched from remote server
    func getGiffyRecommendationsFor(searchedText: String, giffyNetworkService:GiffyRecommendationServiceProtocol, cachedResults: @escaping ([GiffyStruct]) -> (), remoteResults: @escaping ([GiffyStruct]) -> Void)

    /// Given 2 arrays, this function returns values from newList which are not present in oldList
    /// - Parameters:
    ///   - oldList: Old list containg objects of type GiffyStruct
    ///   - newList: New list containg objects of type GiffyStruct
    func filterListForNewItemsOnly(oldList : [GiffyStruct], newList : [GiffyStruct]) -> [GiffyStruct]

    /// Return a list of indexes to be added at the bottom of table view while user is browsing through old recommendations
    /// - Parameters:
    ///   - initialCount: Count of elements currently showing on table view in ViewController
    ///   - newElementsCount: Count of new elements which needs to be added on table view in ViewController
    func getnewIndecesAfter(initialCount: Int, newElementsCount: Int)->[IndexPath]
}

/// GiffyRecommendationServiceProtocol declares function for a GiffyRecommendationService
protocol GiffyRecommendationServiceProtocol{

    /// Fetch Giffy recommendations from remote server for the Presenter
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - completionHandler: A completion block with parsed response data and error optionals
    func requestRecommendationsFor(searchedText : String, completionHandler: @escaping ([GiffyStruct]?, GiffyServiceError?) -> Void)
}

/// GiffyDetailPresenterProtocol  declares functions for Giffy details presenter
protocol GiffyDetailPresenterProtocol{

    /// Fetch Giffy details for the ViewController
    /// - Parameters:
    ///   - searchedText: Text for which detail is requested
    ///   - giffyNetworkService: A service object to perform the remote fetch
    ///   - completionHandler: A completion block with parsed response data and error optionals
    func getGiffyDetailsFor(searchedText: String, giffyNetworkService:GiffyDetailsServiceProtocol, completionHandler: @escaping (String?, GiffyServiceError?) -> Void)
}

/// GiffyDetailsServiceProtocol declares function for a GiffyDetailsService
protocol GiffyDetailsServiceProtocol{

    /// Fetch Giffy details from remote server  for the Presenter
    /// - Parameters:
    ///   - searchedText: Text for which detail is requested
    ///   - completionHandler: A completion block with parsed response data and error optionals
    func requestSearchResultsFor(searchedText : String, completionHandler: @escaping (String?, GiffyServiceError?) -> Void)
}
