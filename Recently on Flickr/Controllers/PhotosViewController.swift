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
    lazy var activityIndicator = createActivityIndicatorView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        collectionView.register(loadingNib, forCellWithReuseIdentifier: "loadingCell")

        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        FlickrClient.getRecentPhotosURL(itemPerPage: itemPerPage, page: currentPage, completion: handleRecentPhotosResponse(success:error:))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func handleRecentPhotosResponse(success: Bool, error: Error?) {
        if success {
            isLoading = false
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            collectionView.reloadData()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            presentError(title: "Loading Images Failed", message: error?.localizedDescription ?? "Unknown Error")
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
            return Photos.allPhotos.count
        } else if section == 1 && isLoading && !activityIndicator.isAnimating {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
            
            if let imageFromCache = Photos.imageCache.object(forKey: Photos.allPhotos[indexPath.item].url.absoluteString as NSString) as? UIImage {
                cell.imageView.image = imageFromCache
            } else {
                cell.imageView.loadImageUsingURL(url: Photos.allPhotos[indexPath.item].url)
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
        photoDetailVC.imageUrlToShow = Photos.allPhotos[indexPath.item].url
        navigationController?.pushViewController(photoDetailVC, animated: true)
    }
    
    // MARK: Calculate the end of the scrollView, and call downloadMorePhotos when the last cell displayed
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
        
        FlickrClient.getRecentPhotosURL(itemPerPage: self.itemPerPage, page: self.currentPage, completion: self.handleRecentPhotosResponse(success:error:))

    }
    
}

// MARK: Flow Layout Methods
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
