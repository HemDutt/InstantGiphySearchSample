//
//  GiphyRecommendationPresenter.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

class GiphyRecommendationPresenter : GiphyRecommendationPresenterProtocol{

    private let giphyNetworkService: GiphyRecommendationServiceProtocol

    init(networkService: GiphyRecommendationServiceProtocol) {
        giphyNetworkService = networkService
    }
    
    func getGiphyRecommendationsFor(searchedText: String, cachedResults: @escaping ([GiphyRecommendationModel], _ indeces:[IndexPath]) -> (), remoteResults: @escaping ([GiphyRecommendationModel], _ newIndeces:[IndexPath]) -> Void, error: @escaping(GiphyServiceError?) -> Void) {
        //Fetch recommendations from cache
        let cachedItems = CacheManager.cache[searchedText]
        if let cachedList = cachedItems as? [GiphyRecommendationModel], !cachedList.isEmpty{
            let indeces = GiphyUtility.getnewIndecesAfter(initialCount: 0, newElementsCount: cachedList.count)
            cachedResults(cachedList, indeces)
        }

        //Fetch recommendations from remote
        giphyNetworkService.requestRecommendationsFor(searchedText: searchedText) { recommendations, err in
            guard err == nil, let remoteRecommendations = recommendations else{
                error(err)
                return
            }
            let cachedResults = cachedItems as? [GiphyRecommendationModel] ?? []
            var newElements = GiphyUtility.filterListForNewItemsOnly(oldList: cachedResults, newList: remoteRecommendations)
            guard !newElements.isEmpty else {
                //If no new results fetched fromm remote, no need to update VC or Cache.
                return
            }

            //Update Cache
            var consolidatedRecommendations = newElements + cachedResults
            consolidatedRecommendations.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
            let cost = GiphyUtility.getCostForInsertingGiphyRecommendations(list: consolidatedRecommendations)
            //Clean old entries
            CacheManager.cache.removeValue(forKey: searchedText)
            //Store new values
            CacheManager.cache.insert(consolidatedRecommendations, forKey: searchedText, insertionCost: cost)

            //Update VC
            newElements.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
            let newIndeces = GiphyUtility.getnewIndecesAfter(initialCount: cachedResults.count, newElementsCount: newElements.count)
            remoteResults(newElements, newIndeces)
        }
    }

    func cancelAllPendingRequests() {
        giphyNetworkService.cancelAllPendingRequests()
    }
}
