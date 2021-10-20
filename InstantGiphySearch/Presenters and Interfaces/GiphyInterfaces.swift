//
//  GiphyInterfaces.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

/// Enum for possible errors during Giphy service calls
enum GiphyServiceError
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
    let data : [GiphyStruct]
}

/// Structure to hold parsed values of recommendations
struct GiphyStruct : Hashable,Decodable {
    let name : String
}

/// GiphyRecommendationPresenterProtocol  declares functions for Giphy recommendation presenter
protocol GiphyRecommendationPresenterProtocol{

    /// Fetch Giphy recommendations from local cache and remote server for the View Controller
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - giphyNetworkService: A service object to perform the remote fetch
    ///   - cachedResults: Recommendation list fetched from local cache
    ///   - remoteResults: Recommendation list fetched from remote server
    func getGiphyRecommendationsFor(searchedText: String, giphyNetworkService:GiphyRecommendationServiceProtocol, cachedResults: @escaping ([GiphyStruct], _ indeces:[IndexPath]) -> (), remoteResults: @escaping ([GiphyStruct], _ newIndeces:[IndexPath]) -> Void)
}

/// GiphyRecommendationServiceProtocol declares function for a GiphyRecommendationService
protocol GiphyRecommendationServiceProtocol{

    /// Fetch Giphy recommendations from remote server for the Presenter
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - completionHandler: A completion block with parsed response data and error optionals
    func requestRecommendationsFor(searchedText : String, completionHandler: @escaping ([GiphyStruct]?, GiphyServiceError?) -> Void)
}

/// GiphyDetailPresenterProtocol  declares functions for Giphy details presenter
protocol GiphyDetailPresenterProtocol{

    /// Fetch Giphy details for the ViewController
    /// - Parameters:
    ///   - searchedText: Text for which detail is requested
    ///   - giphyNetworkService: A service object to perform the remote fetch
    ///   - completionHandler: A completion block with parsed response data and error optionals
    func getGiphyDetailsFor(searchedText: String, giphyNetworkService:GiphyDetailsServiceProtocol, completionHandler: @escaping (String?, GiphyServiceError?) -> Void)
}

/// GiphyDetailsServiceProtocol declares function for a GiphyDetailsService
protocol GiphyDetailsServiceProtocol{

    /// Fetch Giphy details from remote server  for the Presenter
    /// - Parameters:
    ///   - searchedText: Text for which detail is requested
    ///   - completionHandler: A completion block with parsed response data and error optionals
    func requestSearchResultsFor(searchedText : String, completionHandler: @escaping (String?, GiphyServiceError?) -> Void)
}
