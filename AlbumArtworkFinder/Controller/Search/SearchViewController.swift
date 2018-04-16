//
//  SearchViewController.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 12.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var issueLabel: UILabel!
    
    var searchResults = [SearchResult]()
    var sortedSearchResults: [SearchResult] {
        get {
            return searchResults.sorted(by: {$0.collectionName!.lowercased() < $1.collectionName!.lowercased()})
        }
    }
    
    var dataTask: URLSessionDataTask?
    
    lazy var tapRecongnizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        return recognizer
    }()
    
    
    //MARK: - View controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        issueLabel.isHidden = true
        configureCollectionView()
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if navigationController?.topViewController != self {
            navigationController?.navigationBar.isHidden = false
        }
        super.viewWillDisappear(true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.configureCollectionView()
        }
    }
    
    //MARK: - Configuring Collection View
    
    private func configureCollectionView() {
        let screenWidth = Int(view.bounds.width)
        let itemSize = screenWidth / (screenWidth / 100) - 1
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        collectionView.collectionViewLayout = layout
    }
    
    //MARK: - Keyboard dismissial
    
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Networking
    
    private func startRequest(requestType: RequestType, paramKey key: String, paramValue value: String) {
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        issueLabel.isHidden = true
        self.activityIndicator.startAnimating()
        
        NetworkService.configureSessionDataTask(dataTask: &dataTask, requestType: requestType, paramKey: key, paramValue: value,
                                 errorHandler: { (error) in self.handleDataTaskError(error) },
                                 responseHandler: { (requestType, data) in self.handleDataTaskResponse(requestType: requestType, data: data!) }
        )
        dataTask?.resume()
    }
    
    

    //MARK: - Handling networking results
    
    private func handleDataTaskError(_ error: Error) {
        self.activityIndicator.stopAnimating()
        self.issueLabel.isHidden = false
        self.issueLabel.text = error.localizedDescription
        self.searchResults.removeAll()
        self.collectionView.reloadData()
    }
    
    private func handleDataTaskResponse(requestType: RequestType, data: Data) {
        if requestType == .search {
            updateSearhResults(data)
        } else if requestType == .lookup {
            updateAlbumDetailInfo(data)
        }
    }
    
    private func updateSearhResults(_ data: Data?) {
        searchResults.removeAll()
        
        ParseService.parseJSON(data: data, responseType: SearchResponse.self) { (json) in
            if let results = json.results {
                for result in results {
                    searchResults.append(result)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
            if self.searchResults.isEmpty {
                self.issueLabel.isHidden = false
                self.issueLabel.text = "Nothing found"
            }
        }
    }
    
    private func updateAlbumDetailInfo(_ data: Data?) {
        var album = Album()
        
        ParseService.parseJSON(data: data, responseType: LookupResponse.self) { (json) in
            if let results = json.results {
                for result in results {
                    if result.wrapperType == "collection" {
                        album = Album(json: result)
                    } else if result.wrapperType == "track" {
                        album.trackNames.append(result.trackName)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: Id.albumDetailsSegueID, sender: album)
            self.activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Id.albumDetailsSegueID,
            let destination = segue.destination as? DetailsViewController,
            let sender = sender as? Album {
            destination.album = sender
        }
    }
    
}


//MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        if searchBar.text != "" {
            startRequest(requestType: .search, paramKey: "term", paramValue: searchBar.text!)
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecongnizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecongnizer)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" && dataTask != nil {
            dataTask?.cancel()
        }
    }
    
}

//MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Id.resultCollectionViewCellID, for: indexPath) as? ResultCollectionViewCell {
            cell.album = sortedSearchResults[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
    
}

//MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSearchResult = sortedSearchResults[indexPath.item]
        let collectionID = String(describing: selectedSearchResult.collectionId!)
        startRequest(requestType: .lookup, paramKey: "id", paramValue: collectionID)
    }
    
}


