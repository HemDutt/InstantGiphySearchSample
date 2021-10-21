//
//  LaunchRouter.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 20/10/21.
//

import UIKit

protocol ViewBuilderProtocol {
    func buildView() -> UIViewController?
}

struct LaunchViewBuilder : ViewBuilderProtocol{
    func buildView() -> UIViewController? {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let recommendationsViewController = storyBoard.instantiateViewController(withIdentifier: "RecommendationsViewController") as? RecommendationsViewController else{
            print("RecommendationsViewController can't be instantiated")
            return nil
        }

        let sessionConfig = SessionUtility.getDefaultSessionConfig()
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let service = GiphyRecommendationService(session: session)
        let presenter = GiphyRecommendationPresenter(networkService: service)
        recommendationsViewController.giphyPresenter = presenter
        return recommendationsViewController
    }
}
