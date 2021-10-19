//
//  RecommendationsViewController.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 14/10/21.
//

import UIKit

/// View Controller to allow search for a text and get recommendations from Giphy
class RecommendationsViewController: UIViewController {

    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var tableView : UITableView!

    var giphyPresenter : GiphyRecommendationPresenterProtocol?

    private var recommendations : SynchronizedArray<GiphyStruct> = SynchronizedArray()
    //Serial queue to handle recommendations list update without conflict
    private let accessQueue = DispatchQueue(label: "SynchronizedAccess")

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

    /// Reload table view
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - recommendationList: Recommendations for searchedText
    private func reloadTableViewFor(searchedText : String, recommendationList: [GiphyStruct]) {
        accessQueue.sync {
            DispatchQueue.main.async {
                guard searchedText == self.searchBar.text else{
                    //If search bar's current text does not match with the text for which the fetch is perfomed, discard the results.
                    return
                }
                self.recommendations.removeAll()
                self.recommendations.append(newElements: recommendationList)
                self.tableView.reloadData()
            }
        }
    }

    /// Add new items in tableView without disturbing the current context of user
    /// - Parameters:
    ///   - searchedText: Text for which recommendations are requested
    ///   - newElements: New recommendations for searchedText
    ///   - indeces: Indexes which needs to be inserted in table view for new recommendations
    private func insertNewElementsFor(searchedText : String, oldList: [GiphyStruct], newElements: [GiphyStruct], indeces: [IndexPath]){
        accessQueue.sync {
            guard self.recommendations.allItems() == oldList else{
                //If old list do not match, discard the results.
                return
            }
            //Perform UI operations
            DispatchQueue.main.async {
                guard searchedText == self.searchBar.text else{
                    //If search bar's current text does not match with the text for which the fetch is perfomed, discard the results.
                    return
                }
                self.recommendations.append(newElements: newElements)
                self.tableView.performBatchUpdates({
                    self.tableView.insertRows(at: indeces, with: .automatic)
                }, completion: nil)
            }
        }
    }

    /// Fetch recommendations for searchedText if user pause typing in serach field for a configurable time = searchInvocationWait
    /// - Parameter searchedText: Text for which recommendations are requested
    private func fetchAndLoadRecommendationsFor(searchedText: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + searchInvocationWait) {[weak self] in
            guard let self = self, searchedText == self.searchBar.text, let presenter = self.giphyPresenter else{
                return
            }
            guard searchedText.count > 0  else {
                self.tableView.reloadData()
                return
            }
            
            //Fetch recommendations
            let sessionConfig = SessionUtility.getDefaultSessionConfig()
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            var cachedItems : [GiphyStruct] = []
            presenter.getGiphyRecommendationsFor(searchedText: searchedText, giphyNetworkService: GiphyRecommendationService(session: session), cachedResults: { [weak self] cachedList in
                guard let self = self else {
                    return
                }
                //No need to sort as response cached is already sorted
                cachedItems = cachedList
                self.reloadTableViewFor(searchedText: searchedText, recommendationList: cachedList)

            }) {[weak self] remoteList in
                guard let self = self else{
                    return
                }
                self.insertNewElementsFrom(remoteList: remoteList, oldList: cachedItems, searchedText: searchedText)
            }
        }
    }

    /// Prepare new elements in remote list for insertion in table view
    /// - Parameters:
    ///   - remoteList: Recommendations fetched from server
    ///   - searchedText: Text for which recommendations are requested
    private func insertNewElementsFrom(remoteList: [GiphyStruct], oldList: [GiphyStruct], searchedText: String){
        guard let presenter = self.giphyPresenter else {
            return
        }
        let newElements = presenter.filterListForNewItemsOnly(oldList: oldList, newList: remoteList)
        let newIndeces = presenter.getnewIndecesAfter(initialCount: oldList.count, newElementsCount: newElements.count)
        self.insertNewElementsFor(searchedText: searchedText, oldList: oldList, newElements: newElements, indeces: newIndeces)
    }

    private func navigateToDetailScreen(searchedText: String){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.searchedText = searchedText
        detailViewController.detailsPresenter = GiphyDetailPresenter()
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension RecommendationsViewController: UISearchBarDelegate{

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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

