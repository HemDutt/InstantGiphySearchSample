//
//  DetailViewController.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import UIKit

protocol RecommendationDetailsProtocol {
    var searchedText: String? { get set }
}

class DetailViewController: UIViewController, RecommendationDetailsProtocol{

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var searchedText: String?
    var detailsPresenter: GiphyDetailPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let searchStr = searchedText, let presenter = detailsPresenter else {
            return
        }
        activityIndicator.startAnimating()
        presenter.getGiphyDetailsFor(searchedText: searchStr) { response, error in
            DispatchQueue.main.async {[weak self] in
                self?.activityIndicator.stopAnimating()
                self?.textView.text = response
            }
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard let _ = parent else {
            detailsPresenter?.cancelAllPendingRequests()
            return
        }
    }
}
