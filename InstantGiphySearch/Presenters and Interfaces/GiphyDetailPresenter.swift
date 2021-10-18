//
//  GiphyDetailPresenter.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

class GiphyDetailPresenter: GiphyDetailPresenterProtocol{

    func getGiphyDetailsFor(searchedText: String, giphyNetworkService: GiphyDetailsServiceProtocol, completionHandler: @escaping (String?, GiphyServiceError?) -> Void) {
        giphyNetworkService.requestSearchResultsFor(searchedText: searchedText, completionHandler: completionHandler)
    }
}
