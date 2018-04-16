//
//  LookupResult.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 16.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

struct LookupResponse: Decodable {
    var results: [LookupResult]?
}

struct LookupResult: Decodable {
    var wrapperType: String?
    
    var collectionName: String?
    var artistName: String?
    var trackCount: Int?
    var primaryGenreName: String?
    var releaseDate: String?
    var artworkUrl100: String?
    
    var trackName: String?
}
