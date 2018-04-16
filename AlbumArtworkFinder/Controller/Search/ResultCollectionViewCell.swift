//
//  ResultCollectionViewCell.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 13.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit

class ResultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var album: SearchResult? {
        didSet {
            if let artworkUrl = album?.artworkUrl100,
                let url = URL(string: artworkUrl) {
                let data = try? Data(contentsOf: url)
                artworkImageView.image = UIImage(data: data!)
            } else {
                artworkImageView.image = UIImage()
                artworkImageView.backgroundColor = .gray
            }
        }
    }
}
