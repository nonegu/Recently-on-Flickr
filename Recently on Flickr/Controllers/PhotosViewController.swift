//
//  ViewController.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    let itemPerPage = 5
    var isLoading = false
    var currentPage = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        FlickrClient.getRecentPhotosURL(itemPerPage: itemPerPage, page: currentPage, completion: handleRecentPhotosResponse(success:error:))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.collectionView.bounds.width, height: 120)
        }
    }
    
    func handleRecentPhotosResponse(success: Bool, error: Error?) {
        if success {
            isLoading = false
            collectionView.reloadData()
        } else {
            print(error!)
        }
    }

}

// MARK: DataSource methods
extension PhotosViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Photos.URLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
        
        cell.imageView.image = nil
        FlickrClient.getPhotoData(from: Photos.URLs[indexPath.item]) { (data, error) in
            if let data = data, let image = UIImage(data: data) {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
}

// MARK: Delegate methods
extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !isLoading {
                downloadMorePhotos()
            }
        }
    }
    
    func downloadMorePhotos() {
        isLoading = true
        currentPage += 1
        print("downloading new photos")
        
        DispatchQueue.main.async {
            FlickrClient.getRecentPhotosURL(itemPerPage: self.itemPerPage, page: self.currentPage, completion: self.handleRecentPhotosResponse(success:error:))
        }
    }
    
}

