//
//  Album.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 13.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

struct Album {
    var collectionName: String?
    var artistName: String?
    var trackCount: Int?
    var primaryGenreName: String?
    var releaseDate: String?
    var artworkUrl100: String?
    
    var trackNames: [String?] = []
    
    init() {}
    
    init(json: LookupResult) {
        self.collectionName = json.collectionName
        self.artistName = json.artistName
        self.trackCount = json.trackCount
        self.primaryGenreName = json.primaryGenreName
        self.artworkUrl100 = json.artworkUrl100
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'hh:mm:ss'Z'"
        let parsedReleaseDate = json.releaseDate
        let releaseDateObj = dateFormatter.date(from: parsedReleaseDate!)
        dateFormatter.dateFormat = "MMM dd, YYYY"
        dateFormatter.locale = Locale(identifier: "en_US")
        self.releaseDate = dateFormatter.string(from: releaseDateObj!)
    }

}


