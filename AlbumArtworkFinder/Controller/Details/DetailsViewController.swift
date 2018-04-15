//
//  DetailsViewController.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 13.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import Foundation

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var numberOfTracksLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var album: Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIWithAlbumData()
    }
    
    func updateUIWithAlbumData() {
        albumNameLabel.text = album?.collectionName
        artistNameLabel.text = album?.artistName
        numberOfTracksLabel.text = "\((album?.trackCount!)!) tracks"
        genreLabel.text = album?.primaryGenreName
        releaseDateLabel.text = album?.releaseDate
        
        if let artwork = album?.artworkUrl100 {
            let data = try? Data(contentsOf: URL(string: artwork)!)
            albumImageView.image = UIImage(data: data!)
        } else {
            albumImageView.image = UIImage()
            albumImageView.backgroundColor = .gray
            albumImageView.frame.size = CGSize(width: 100, height: 100)
        }
    }
    
}

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
