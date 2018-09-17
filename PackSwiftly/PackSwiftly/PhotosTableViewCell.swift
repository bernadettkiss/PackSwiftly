//
//  PhotosTableViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/14/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

protocol PhotosTableViewCellDelegate: class {
    func didSelect(image: Data)
}

class PhotosTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var photos = [Photo]()
    weak var delegate: PhotosTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        configureFlowLayout()
    }
    
    func getPhotos(latitude: Double, longitude: Double, text: String) {
        FlickrClient.shared.getPhotos(latitude: latitude, longitude: longitude, text: text) { (result) in
            if case let .success(parsedPhotos) = result {
                self.photos = parsedPhotos
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func configureFlowLayout() {
        let space: CGFloat = 3.0
        var numberOfColumns: CGFloat = 3
        if contentView.frame.size.width > contentView.frame.size.height {
            numberOfColumns = 5.0
        }
        let dimension = (contentView.frame.size.width - ((numberOfColumns - 1) * space)) / numberOfColumns
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: - CollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = photos[indexPath.item]
        
        let imageURL = photo.remoteURL
        NetworkManager.shared.downloadImage(imageURL: imageURL) { result in
            if case let .success(imageData) = result {
                self.photos[indexPath.item].imageData = imageData as? Data
                let image = UIImage(data: imageData as! Data)
                DispatchQueue.main.async {
                    cell.update(with: image!)
                }
            }
        }
        return cell
    }
    
    // MARK: - CollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let imageData = photos[indexPath.item].imageData {
            delegate?.didSelect(image: imageData)
        }
    }
}
