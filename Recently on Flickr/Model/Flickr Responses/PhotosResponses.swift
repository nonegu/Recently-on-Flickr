//
//  PhotosResponses.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

struct PhotosResponses: Codable {
    let photos: PhotoResponses
    let stat: String
}

struct PhotoResponses: Codable {
    let currentPage: Int
    let totalPages: Int
    let itemsPerPage: Int
    let totalPhotos: Int
    let photo: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "page"
        case totalPages = "pages"
        case itemsPerPage = "perpage"
        case totalPhotos = "total"
        case photo
    }
}
