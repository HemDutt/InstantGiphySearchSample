//
//  GiffyInterfaces.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

struct SearchSuggestions : Decodable {
    let data : [GiffyStruct]
}

struct GiffyStruct : Hashable,Decodable {
    let name : String
}

protocol GiffyRecommendationPresenterProtocol{
    func getGiffyRecommendationsFor(searchedText: String, giffyNetworkService:GiffyRecommendationServiceProtocol, cachedResults: @escaping ([GiffyStruct]) -> (), remoteResults: @escaping ([GiffyStruct]) -> Void)

    func filterListForNewItemsOnly(oldList : [GiffyStruct], newList : [GiffyStruct]) -> [GiffyStruct]

    func getnewIndecesAfter(initialCount: Int, newElementsCount: Int)->[IndexPath]
}

protocol GiffyRecommendationServiceProtocol{
    func requestRecommendationsFor(searchedText : String, completionHandler: @escaping ([GiffyStruct]?, GiffyServiceError?) -> Void)
}

protocol GiffyDetailPresenterProtocol{
    func getGiffyDetailsFor(searchedText: String, giffyNetworkService:GiffyDetailsServiceProtocol, completionHandler: @escaping (String?, GiffyServiceError?) -> Void)
}

protocol GiffyDetailsServiceProtocol{
    func requestSearchResultsFor(searchedText : String, completionHandler: @escaping (String?, GiffyServiceError?) -> Void)
}
