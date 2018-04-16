//
//  ParseService.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 16.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

class ParseService {
    //MARK: - Parsing JSON
        
    class func parseJSON<T:Decodable>(data: Data?, responseType: T.Type, completion: (T) -> Void) {
        do {
            if let data = data{
                let json = try JSONDecoder().decode(T.self, from: data)
                completion(json)
            }
        } catch let jsonErr {
            print("Parsing error: \(jsonErr.localizedDescription)")
        }
    }
}
