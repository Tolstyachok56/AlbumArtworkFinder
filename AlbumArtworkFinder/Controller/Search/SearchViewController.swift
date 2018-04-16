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
    
    //MARK: - Configuring Collection View
    
    private func configureCollectionView() {
        let screenWidth = Int(UIScreen.main.bounds.width)
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
    
    private enum RequestType: String {
        case search = "https://itunes.apple.com/search?media=music&entity=album&"
        case lookup = "https://itunes.apple.com/lookup?media=music&entity=song&"
    }
    
    private func createRequest(ofType type: RequestType, parameterKey key: String, parameterValue: String) {
        if dataTask != nil {
            dataTask?.cancel()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activityIndicator.startAnimating()
        
        let value = parameterValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "\(type.rawValue)\(key)=\(value)")
        dataTask = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = error {
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
    
    //MARK: - Handling request results
    
    private func parseJSON(data: Data?, completion: ([String:AnyObject]) -> Void) {
        do {
            if let data = data,
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                
                if let array: AnyObject = json["results"] {
                    for dictionary in array as! [AnyObject] {
                        if let albumDictionary = dictionary as? [String:AnyObject] {
                            completion(albumDictionary)
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
            }
        } catch let jsonErr {
            print("Parsing error: \(jsonErr.localizedDescription)")
        }
    }
    
    private func updateSearhResults(_ data: Data?) {
        searchResults.removeAll()
        
        parseJSON(data: data) { (albumDictionary) in
            searchResults.append(SearchResult(dict: albumDictionary))
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func updateAlbumDetailInfo(_ data: Data?) {
        var album = Album()
        
        parseJSON(data: data) { (albumDictionary) in
            if let wrapperType = albumDictionary["wrapperType"] as? String{
                if wrapperType == "collection" {
                    album = Album(dict: albumDictionary)
                } else if wrapperType == "track" {
                    album.trackNames.append(albumDictionary["trackName"] as? String)
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
        createRequest(ofType: .search, parameterKey: "term", parameterValue: searchBar.text!)
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

