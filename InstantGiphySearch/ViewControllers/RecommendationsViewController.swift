//
//  RecommendationsViewController.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import UIKit

/// View Controller to allow search for a text and get recommendations from Giffy
class RecommendationsViewController: UIViewController {

    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var tableView : UITableView!

    var giffyPresenter : GiffyRecommendationPresenterProtocol?

    private var recommendations : [GiffyStruct] = []
    private let cellIdentifier = "GiffyResultCell"
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

    /// Reload table view
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - recommendationList: Recommendations for searchedText
    private func reloadTableViewFor(searchedText : String, recommendationList: [GiffyStruct]) {
        DispatchQueue.main.async {
            guard searchedText == self.searchBar.text else{
                //If search bar's current text does not match with the text for which the fetch is perfomed, discard the results.
                return
            }
            self.recommendations = recommendationList
            self.tableView.reloadData()
        }
    }

    /// Add new items in tableView without disturbing the current context of user
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - newElements: New recommendations for searchedText
    ///   - indeces: Indexes which needs to be inserted in table view for new recommendations
    private func insertNewElementsFor(searchedText : String, newElements: [GiffyStruct], indeces: [IndexPath]){
        DispatchQueue.main.async {
            guard searchedText == self.searchBar.text else{
                //If search bar's current text does not match with the text for which the fetch is perfomed, discard the results.
                return
            }
            self.recommendations.append(contentsOf: newElements)
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indeces, with: .automatic)
            }, completion: nil)
        }
    }


    /// Fetch recommendations for searchedText if user pause typing in serach field for a configurable time = searchInvocationWait
    /// - Parameter searchedText: Text for which recommendations are requested
    private func fetchAndLoadRecommendationsFor(searchedText: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + searchInvocationWait) {[weak self] in
            guard let self = self, searchedText == self.searchBar.text else{
                return
            }
            guard let presenter = self.giffyPresenter else {
                return
            }
            //Fetch recommendations
            let sessionConfig = SessionUtility.getDefaultSessionConfig()
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            presenter.getGiffyRecommendationsFor(searchedText: searchedText, giffyNetworkService: GiffyRecommendationService(session: session), cachedResults: { [weak self] cachedList in
                guard let self = self, self.recommendations.count == 0 else {
                    //If list is aready populated with latest remote data.
                    //This might happen in rare case where cached list is too big as compared to latest remote data.
                    //In this case we will just discard the cahed response.
                    return
                }
                var cachedElements = cachedList
                //Sort Alphabatically
                cachedElements.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
                self.reloadTableViewFor(searchedText: searchedText, recommendationList: cachedList)

            }) {[weak self] remoteList in
                self?.insertNewElementsFrom(remoteList: remoteList, searchedText: searchedText)
            }
        }
    }

    /// Prepare new elements in remote list for insertion in table view
    /// - Parameters:
    ///   - remoteList: Recommendations fetched from server
    ///   - searchedText: Text for which recommendations are requested
    private func insertNewElementsFrom(remoteList: [GiffyStruct], searchedText: String){
        guard let presenter = self.giffyPresenter else {
            return
        }
        var newElements = presenter.filterListForNewItemsOnly(oldList: self.recommendations, newList: remoteList)
        //Sort Alphabatically
        newElements.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
        let newIndeces = presenter.getnewIndecesAfter(initialCount: self.recommendations.count, newElementsCount: newElements.count)
        self.insertNewElementsFor(searchedText: searchedText, newElements: newElements, indeces: newIndeces)
    }

    private func navigateToDetailScreen(searchedText: String){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.searchedText = searchedText
        detailViewController.detailsPresenter = GiffyDetailPresenter()
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension RecommendationsViewController: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Clear recommendations when text change
        self.recommendations = []
        guard searchText.count > 0  else {
            tableView.reloadData()
            return
        }
        fetchAndLoadRecommendationsFor(searchedText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchedText = searchBar.text, searchedText.count > 0  else {
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

