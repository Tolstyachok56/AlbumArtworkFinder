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
        issueLabel.isHidden = true
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
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
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAlbumInfo",
            let destination = segue.destination as? DetailsViewController,
            let sender = sender as? Album {
            destination.album = sender
        }
    }
    
    //MARK: - Networking
    
    private func createRequest(ofType type: RequestType, parameterKey key: String, parameterValue: String) {
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        issueLabel.isHidden = true
        self.activityIndicator.startAnimating()
        
        let value = parameterValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "\(type.rawValue)\(key)=\(value)")
        dataTask = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.issueLabel.isHidden = false
                    self.issueLabel.text = "Connection issues"
                    self.searchResults.removeAll()
                    self.collectionView.reloadData()
                }
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    switch type {
                    case .search:
                        self.updateSearhResults(data)
                    case .lookup:
                        self.updateAlbumDetailInfo(data)
                    }
                }
            }
            
        })
        dataTask?.resume()
    }
    
    //MARK: - Parsing JSON
    
    private func parseJSON<T:Decodable>(data: Data?, responseType: T.Type, completion: (T) -> Void) {
        do {
            if let data = data{
                let json = try JSONDecoder().decode(T.self, from: data)
                completion(json)
            }
        } catch let jsonErr {
            print("Parsing error: \(jsonErr.localizedDescription)")
        }
    }
    
    //MARK: - Handling request results
    
    private func updateSearhResults(_ data: Data?) {
        searchResults.removeAll()
        
        parseJSON(data: data, responseType: SearchResponse.self) { (json) in
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
        
        parseJSON(data: data, responseType: LookupResponse.self) { (json) in
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
            self.performSegue(withIdentifier: "toAlbumInfo", sender: album)
            self.activityIndicator.stopAnimating()
        }
    }
    
}

//MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        if searchBar.text != "" {
            createRequest(ofType: .search, parameterKey: "term", parameterValue: searchBar.text!)
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultCell", for: indexPath) as? ResultCollectionViewCell {
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
        createRequest(ofType: .lookup, parameterKey: "id", parameterValue: String(describing: selectedSearchResult.collectionId!))
    }
    
}


