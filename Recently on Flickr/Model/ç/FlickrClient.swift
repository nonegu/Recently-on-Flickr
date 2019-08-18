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
    
    class func getRecentPhotosURL(itemPerPage: Int, page: Int, completion: @escaping (Bool, Error?) -> Void) {
        let getRecentPhotosURL = Endpoints.getRecentPhotos(itemPerPage: itemPerPage, page: page).url
        let task = URLSession.shared.dataTask(with: getRecentPhotosURL) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(PhotosResponses.self, from: data)
                DispatchQueue.main.async {
                    createPhotoURLsFrom(response: response)
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponses.self, from: data)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(String(data: data, encoding: .utf8)!)
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func getPhotoData(from URL: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: URL) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
    
    class func createPhotoURLsFrom(response: PhotosResponses, size: String = "q") {
        for photo in response.photos.photo {
            let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg")!
            let newPhoto = PhotoModel(url: photoURL, title: photo.title)
            Photos.allPhotos.append(newPhoto)
        }
    }
    
}
