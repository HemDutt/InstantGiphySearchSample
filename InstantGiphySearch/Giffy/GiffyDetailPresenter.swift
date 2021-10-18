//
//  GiffyDetailPresenter.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

class GiffyDetailPresenter: GiffyDetailPresenterProtocol{

    func getGiffyDetailsFor(searchedText: String, giffyNetworkService: GiffyDetailsServiceProtocol, completionHandler: @escaping (String?, GiffyServiceError?) -> Void) {
        giffyNetworkService.requestSearchResultsFor(searchedText: searchedText, completionHandler: completionHandler)
    }
}
