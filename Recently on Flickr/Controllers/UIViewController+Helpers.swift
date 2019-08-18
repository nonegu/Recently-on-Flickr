//
//  UIViewController+Helpers.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 18.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    // MARK: Alerts
    func presentError(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Creating an Activity Indicator
    func createActivityIndicatorView() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.center = view.center
        indicator.color = UIColor.black
        return indicator
    }

}
