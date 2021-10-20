//
//  GiphyDetailPresenter.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

class GiphyDetailPresenter: GiphyDetailPresenterProtocol{

    private let giphyNetworkService : GiphyDetailsServiceProtocol

    init(networkService: GiphyDetailsServiceProtocol) {
        giphyNetworkService = networkService
    }

    func getGiphyDetailsFor(searchedText: String, completionHandler: @escaping (String?, GiphyServiceError?) -> Void) {
        giphyNetworkService.requestSearchResultsFor(searchedText: searchedText, completionHandler: completionHandler)
    }

    func cancelAllPendingRequests() {
        giphyNetworkService.cancelAllPendingRequests()
    }
}

