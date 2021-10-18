//
//  DetailViewController.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import UIKit

class DetailViewController: UIViewController{

    @IBOutlet var textView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var searchedText: String?
    var detailsPresenter: GiffyDetailPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let searchStr = searchedText, let presenter = detailsPresenter else {
            return
        }
        activityIndicator.startAnimating()
        let sessionConfig = SessionUtility.getDefaultSessionConfig()
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        presenter.getGiffyDetailsFor(searchedText: searchStr, giffyNetworkService: GiffyDetailsService(session: session)) { response, error in
            DispatchQueue.main.async {[weak self] in
                self?.activityIndicator.stopAnimating()
                self?.textView.text = response
            }
        }
    }
}
