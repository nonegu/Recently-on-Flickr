//
//  ViewController.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        FlickrClient.getRecentPhotosURL(itemPerPage: 5, page: 1, completion: handleRecentPhotosResponse(success:error:))
    }
    
    func handleRecentPhotosResponse(success: Bool, error: Error?) {
        if success {
            for url in Photos.URLs {
                FlickrClient.getPhotoData(from: url, completion: handlePhotoData(data:error:))
            }
        } else {
            print(error)
        }
    }
    
    func handlePhotoData(data: Data?, error: Error?) {
        guard let data = data else {
            print(error)
            return
        }
        let downloadedImage = UIImage(data: data)
        DispatchQueue.main.async {
            self.imageView.image = downloadedImage
        }
    }


}

