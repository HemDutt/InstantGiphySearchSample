//
//  GiphyRecommendationPresenter.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import Foundation

class GiphyRecommendationPresenter : GiphyRecommendationPresenterProtocol{
    
    func getGiphyRecommendationsFor(searchedText: String, giphyNetworkService:GiphyRecommendationServiceProtocol, cachedResults: @escaping ([GiphyStruct]) -> (), remoteResults: @escaping ([GiphyStruct]) -> Void) {
        //Fetch recommendations from cache
        let cachedItems = CacheManager.cache[searchedText] as? [GiphyStruct]
        cachedResults(cachedItems ?? [])

        //Fetch recommendations from remote
        giphyNetworkService.requestRecommendationsFor(searchedText: searchedText) { recommendations, error in
            guard error == nil else{
                //Do nothing for now.
                //We can log and propagate error later
                return
            }

            CacheManager.cache[searchedText] = recommendations ?? []
            remoteResults(recommendations ?? [])
        }
    }

    func filterListForNewItemsOnly(oldList : [GiphyStruct], newList : [GiphyStruct]) -> [GiphyStruct]{
        return Array(Set(newList).subtracting(oldList))
    }

    func getnewIndecesAfter(initialCount: Int, newElementsCount: Int)->[IndexPath]{
        var indeces : [IndexPath] = []
        for index in 0..<newElementsCount{
            indeces.append(IndexPath(row: index + initialCount, section: 0))
        }
        return indeces
    }
}
