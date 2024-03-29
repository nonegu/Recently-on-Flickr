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
    var photoViewModel = PhotoViewModel()
    var imageUrlToShow: URL!
    lazy var activityIndicator = createActivityIndicatorView()
    
    // MARK: Outlets
    @IBOutlet weak var detailImageView: UIImageView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        photoViewModel.getPhotoData(from: photoViewModel.getOriginalImageUrl(url: imageUrlToShow)) { (data, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.detailImageView.image = image
                }
            } else {
                self.presentError(title: "Loading Original Image Failed", message: "Please check your connection")
            }
        }
    }

}
