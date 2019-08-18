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
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.center = view.center
        indicator.color = UIColor.black
        return indicator
    }()
    
    // MARK: Outlets
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        FlickrClient.getPhotoData(from: getOriginalImageUrl(url: imageUrlToShow)) { (data, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.detailImageView.image = image
                }
            }
        }
    }
    
    func getOriginalImageUrl(url: URL) -> URL {
        let imageUrlString = imageUrlToShow.absoluteString
        let startIndex = imageUrlString.index(imageUrlString.endIndex, offsetBy: -6)
        let endIndex = imageUrlString.endIndex
        
        let originalImageUrlString = imageUrlString.replacingCharacters(in: startIndex..<endIndex, with: ".jpg")
        let originalImageUrl = URL(string: originalImageUrlString)!
        
        return originalImageUrl
    }

}
