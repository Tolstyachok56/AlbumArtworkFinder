//
//  Album.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 13.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

class Album {
    var collectionName: String?
    var artistName: String?
    var trackCount: Int?
    var primaryGenreName: String?
    var releaseDate: String?
    var artworkUrl100: String?
    
    var trackNames: [String?] = []
    
    init() {}
    
    init(dict: [String: AnyObject]) {
        self.collectionName = dict["collectionName"] as? String
        self.artistName = dict["artistName"] as? String
        self.trackCount = dict["trackCount"] as? Int
        self.primaryGenreName = dict["primaryGenreName"] as? String
        self.artworkUrl100 = dict["artworkUrl100"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'hh:mm:ss'Z'"
        let parsedReleaseDate = dict["releaseDate"] as? String
        let releaseDateObj = dateFormatter.date(from: parsedReleaseDate!)
        dateFormatter.dateFormat = "MMM dd, YYYY"
        self.releaseDate = dateFormatter.string(from: releaseDateObj!)
    }

}
