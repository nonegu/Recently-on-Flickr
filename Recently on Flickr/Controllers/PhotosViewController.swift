//
//  ViewController.swift
//  Recently on Flickr
//
//  Created by Ender Güzel on 17.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    // MARK: Properties
    var photoViewModel = PhotoViewModel()
    var imageCache = NSCache<AnyObject, UIImage>()
    let itemPerPage = 20
    var isLoading = false
    var currentPage = 1
    let imageCellIdentifier = "Cell"
    let loadingCellIdentifier = "loadingCell"
    lazy var activityIndicator = createActivityIndicatorView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loadingNib = UINib(nibName: "LoadingCell", bundle: nil)
        collectionView.register(loadingNib, forCellWithReuseIdentifier: loadingCellIdentifier)

        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        setupViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setupViewModel() {
        // reload handler will be called when the urls of the photos created.
        photoViewModel.reloadHandler = {
            self.collectionView.reloadData()
        }
        photoViewModel.fetchPhotos(itemPerPage: itemPerPage, page: currentPage, completion: handleRecentPhotosResponse(success:error:))
    }
    
    func downloadMorePhotos() {
        isLoading = true
        currentPage += 1
        print("downloading new photos")
        collectionView.reloadSections(IndexSet(integer: 1))
        
        setupViewModel()
    }
    
    func handleRecentPhotosResponse(success: Bool, error: Error?) {
        if success {
            isLoading = false
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
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
            return photoViewModel.itemCount
        } else if section == 1 && isLoading && !activityIndicator.isAnimating {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as! CustomCollectionViewCell
            
            if let imageFromCache = imageCache.object(forKey: photoViewModel.photos[indexPath.item].url.absoluteString as NSString) {
                cell.imageView.image = imageFromCache
            } else {
                cell.imageView.loadImageUsingURL(url: photoViewModel.photos[indexPath.item].url, imageCache: imageCache)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellIdentifier, for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
        
    }
    
}

// MARK: Delegate methods
extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoDetailVC = storyboard?.instantiateViewController(withIdentifier: "photoDetailView") as! PhotoDetailViewController
        photoDetailVC.imageUrlToShow = photoViewModel.photos[indexPath.item].url
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
