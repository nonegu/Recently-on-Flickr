//
//  UIImageView+Helpers.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 19.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageUsingURL(url: URL, imageCache: NSCache<AnyObject, UIImage>?) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!)
                return
            }
            if let image = UIImage(data: data) {
                if let imageCache = imageCache {
                    imageCache.setObject(image, forKey: (url.absoluteString as NSString))
                }
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        task.resume()
    }
}
