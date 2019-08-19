//
//  FlickrClient.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

class FlickrClient {
    
    static let apiKey = "ENTER_YOUR_API_KEY_HERE"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        static let jsonFormatParam = "&format=json&nojsoncallback=1"
        
        case getRecentPhotos(itemPerPage: Int, page: Int)
        
        var stringValue: String {
            switch self {
            case .getRecentPhotos(let itemPerPage, let page):
                return Endpoints.base + "?method=flickr.photos.getRecent" + Endpoints.apiKeyParam + "&per_page=\(itemPerPage)" + "&page=\(page)" + Endpoints.jsonFormatParam
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
}
