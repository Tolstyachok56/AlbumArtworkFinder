//
//  NetworkService.swift
//  AlbumArtworkFinder
//
//  Created by Виктория Бадисова on 16.04.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import Foundation

class NetworkService {
    
    class func configureSessionDataTask (dataTask: inout URLSessionDataTask?, requestType: RequestType, paramKey key: String, paramValue: String, errorHandler: @escaping (Error) -> Void, responseHandler: @escaping (RequestType, Data?) -> Void) {
        let value = paramValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "\(requestType.rawValue)\(key)=\(value)")
        dataTask = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    errorHandler(error)
                }
                print("URLSession error: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    responseHandler(requestType, data)
                } else {
                    let statusCode = httpResponse.statusCode
                    let statusCodeString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    print("Status code \(statusCode): \(statusCodeString)")
                }
            }
        })
    }
    
}
