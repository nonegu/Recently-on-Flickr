//
//  ViewController.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    let itemPerPage = 20
    var isLoading = false
    var currentPage = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        collectionView.register(loadingNib, forCellWithReuseIdentifier: "loadingCell")
        FlickrClient.getRecentPhotosURL(itemPerPage: itemPerPage, page: currentPage, completion: handleRecentPhotosResponse(success:error:))
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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return Photos.URLs.count
        } else if section == 1 && isLoading {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
            cell.imageView.image = nil
            
            if let imageFromCache = Photos.imageCache.object(forKey: Photos.URLs[indexPath.item].absoluteString as NSString) as? UIImage {
                cell.imageView.image = imageFromCache
            } else {
                cell.imageView.loadImageUsingURL(url: Photos.URLs[indexPath.item])
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
        
    }
    
}

// MARK: Delegate methods
extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoDetailVC = storyboard?.instantiateViewController(withIdentifier: "photoDetailView") as! PhotoDetailViewController
        photoDetailVC.imageUrlToShow = Photos.URLs[indexPath.row]
        navigationController?.pushViewController(photoDetailVC, animated: true)
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
        collectionView.reloadSections(IndexSet(integer: 1))
        
        DispatchQueue.main.async {
            FlickrClient.getRecentPhotosURL(itemPerPage: self.itemPerPage, page: self.currentPage, completion: self.handleRecentPhotosResponse(success:error:))
        }
    }
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let padding: CGFloat = 10
            let collectionViewSize = collectionView.frame.size.width - padding
            
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: 50)
        }
    }
    
}

extension UIImageView {
    
    func loadImageUsingURL(url: URL) {
        FlickrClient.getPhotoData(from: url) { (data, error) in
            if let data = data, let image = UIImage(data: data) {
                Photos.imageCache.setObject(image, forKey: (url.absoluteString as NSString))
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
