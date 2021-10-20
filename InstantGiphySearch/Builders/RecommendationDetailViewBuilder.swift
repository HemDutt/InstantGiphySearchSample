//
//  RecommendationDetailViewBuilder.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 20/10/21.
//

import UIKit

struct RecommendationDetailViewBuilder : ViewBuilderProtocol{
    func buildView() -> UIViewController? {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else{
            print("DetailViewController can't be instantiated")
            return nil
        }

        let sessionConfig = SessionUtility.getDefaultSessionConfig()
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let service = GiphyDetailsService(session: session)
        detailViewController.detailsPresenter = GiphyDetailPresenter(networkService: service)
        return detailViewController
    }
}
