//
//  SearchResult.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 12.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

struct SearchResponse: Decodable {
    var results: [SearchResult]?
}

struct SearchResult: Decodable {
    var collectionName: String?
    var artworkUrl100: String?
    var collectionId: Int?
}
