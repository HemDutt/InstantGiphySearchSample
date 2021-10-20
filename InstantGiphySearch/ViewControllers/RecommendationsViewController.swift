//
//  RecommendationsViewController.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import UIKit

/// View Controller to allow search for a text and get recommendations from Giphy
class RecommendationsViewController: UIViewController {

    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var tableView : UITableView!

    var giphyPresenter : GiphyRecommendationPresenterProtocol?

    private var recommendations : SynchronizedArray<GiphyStruct> = SynchronizedArray()
    private var latestSearchTimeStamp : String = ""
    private let cellIdentifier = "GiphyResultCell"
    // If user pause typing in search bar for time = searchInvocationWait, invoke fetch recommendation routine.
    private let searchInvocationWait = 0.2    //200 ms

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }

    /// Add new items in tableView without disturbing the current context of user
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - oldList: oldList in which newElements should be appended
    ///   - newElements: New recommendations for searchedText
    ///   - indeces: Indexes which needs to be inserted in table view for new recommendations
    private func insertNewElementsFor(searchedText : String, timeStamp: String, newElements: [GiphyStruct], indeces: [IndexPath]){
        //Perform Batch updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self, timeStamp == self.latestSearchTimeStamp  else{
                //If timestamp of searched text do not match with latestSearchTimeStamp, do not perform batch updates.
                return
            }
            self.recommendations.append(newElements: newElements)
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: indeces, with: .automatic)
            } completion: { success in
            }
        }
    }

    private func clearRecommendations(){
        DispatchQueue.main.async {[weak self] in
            self?.recommendations.removeAll()
            self?.tableView.reloadData()
        }
    }

    /// Fetch recommendations for searchedText if user pause typing in serach field for a configurable time = searchInvocationWait
    /// - Parameter searchedText: Text for which recommendations are requested
    private func fetchAndLoadRecommendationsFor(searchedText: String, timeStamp: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + searchInvocationWait) {[weak self] in
            guard let self = self, timeStamp == self.latestSearchTimeStamp, let presenter = self.giphyPresenter else{
                //Discard searches with old timestamp.
                return
            }
            //Clear old recommendations
            self.clearRecommendations()
            guard !searchedText.isEmpty else {
                return
            }
            
            //Fetch recommendations
            let sessionConfig = SessionUtility.getDefaultSessionConfig()
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            presenter.getGiphyRecommendationsFor(searchedText: searchedText, giphyNetworkService: GiphyRecommendationService(session: session), cachedResults: { [weak self] cachedItems, indeces  in
                self?.insertNewElementsFor(searchedText: searchedText, timeStamp: timeStamp, newElements: cachedItems, indeces: indeces)
            }) {[weak self] remoteList, indeces  in
                self?.insertNewElementsFor(searchedText: searchedText, timeStamp: timeStamp, newElements: remoteList, indeces: indeces)
            }
        }
    }

    private func navigateToDetailScreen(searchedText: String){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else{
            print("DetailViewController can't be instantiated")
            return
        }
        detailViewController.searchedText = searchedText
        detailViewController.detailsPresenter = GiphyDetailPresenter()
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension RecommendationsViewController: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        latestSearchTimeStamp = GiphyUtility.getTimeStammp()
        fetchAndLoadRecommendationsFor(searchedText: searchText, timeStamp: latestSearchTimeStamp)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchedText = searchBar.text, !searchedText.isEmpty  else {
            return
        }
        navigateToDetailScreen(searchedText: searchedText)
        searchBar.endEditing(true)
    }
}

extension RecommendationsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recommendations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = recommendations[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension RecommendationsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToDetailScreen(searchedText: recommendations[indexPath.row].name)
        searchBar.endEditing(true)
    }
}

