//
//  ResultCollectionViewCell.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 13.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import SDWebImage

class ResultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    
    var album: SearchResult? {
        didSet {
            artworkImageView.backgroundColor = .gray
            if let imageUrl = album?.artworkUrl100 {
                let url = URL(string: imageUrl)
                artworkImageView.sd_setImage(with: url!, placeholderImage: UIImage())
            } else {
                artworkImageView.image = UIImage()
            }
        }
    }
}
