//
//  PhotoViewModel.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 19.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

typealias DataHandler = () -> Void

class PhotoViewModel {
    
    var photos: [PhotoModel] = []
    var reloadHandler: DataHandler = { }
    
    var itemCount: Int {
        return self.photos.count
    }
    
    func fetchPhotos(itemPerPage: Int, page: Int, completion: @escaping (Bool, Error?) -> Void) {
        let getRecentPhotosURL = FlickrClient.Endpoints.getRecentPhotos(itemPerPage: itemPerPage, page: page).url
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
                    self.createPhotoURLsFrom(response: response)
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
    
    private func createPhotoURLsFrom(response: PhotosResponses, size: String = "q") {
        for photo in response.photos.photo {
            let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg")!
            let newPhoto = PhotoModel(url: photoURL, title: photo.title)
            photos.append(newPhoto)
        }
        reloadHandler()
    }
    
    func getPhotoData(from URL: URL, completion: @escaping (Data?, Error?) -> Void) {
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
    
    // MARK: Changing the URL to display image with better quality.
    func getOriginalImageUrl(url: URL) -> URL {
        let imageUrlString = url.absoluteString
        let startIndex = imageUrlString.index(imageUrlString.endIndex, offsetBy: -6)
        let endIndex = imageUrlString.endIndex
        
        let originalImageUrlString = imageUrlString.replacingCharacters(in: startIndex..<endIndex, with: ".jpg")
        let originalImageUrl = URL(string: originalImageUrlString)!
        
        return originalImageUrl
    }
    
}
