//
//  DetailsViewController.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 13.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var numberOfTracksLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var album: Album?
    
    //MARK: - View controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIWithAlbumData()
    }
    
    //MARK: - Updating UI with album data
    
    private func updateUIWithAlbumData() {
        albumNameLabel.text = album?.collectionName
        artistNameLabel.text = album?.artistName
        numberOfTracksLabel.text = "\((album?.trackCount!)!) tracks"
        genreLabel.text = album?.primaryGenreName
        releaseDateLabel.text = album?.releaseDate
        
        albumImageView.backgroundColor = .gray
        if let artwork = album?.artworkUrl100 {
            albumImageView.sd_setImage(with: URL(string: artwork)!, placeholderImage: UIImage())
        } else {
            albumImageView.image = UIImage()
        }
    }
    
}

//MARK: - UITableViewDataSource

extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (album?.trackNames.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let trackName = (album?.trackNames[indexPath.row])!
        cell.textLabel?.text = "\(indexPath.row + 1). \(trackName)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
}
