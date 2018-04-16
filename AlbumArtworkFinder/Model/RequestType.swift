//
//  RequestType.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 16.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

enum RequestType: String {
    case search = "https://itunes.apple.com/search?media=music&entity=album&"
    case lookup = "https://itunes.apple.com/lookup?media=music&entity=song&"
}
