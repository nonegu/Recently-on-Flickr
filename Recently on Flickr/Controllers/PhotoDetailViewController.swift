//
//  PhotoDetailViewController.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    // MARK: Variables
    var imageUrlToShow: URL!
    
    // MARK: Outlets
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FlickrClient.getPhotoData(from: imageUrlToShow) { (data, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.detailImageView.image = image
                }
            }
        }
    }

}
