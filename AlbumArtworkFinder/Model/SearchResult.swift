//
//  SearchResult.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 12.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

struct SearchResult {
    var collectionName: String?
    var artworkUrl100: String?
    var collectionId: Int?
    
    init(dict: [String: AnyObject]) {
        self.collectionName = dict["collectionName"] as? String
        self.artworkUrl100 = dict["artworkUrl100"] as? String
        self.collectionId = dict["collectionId"] as? Int
    }
}
