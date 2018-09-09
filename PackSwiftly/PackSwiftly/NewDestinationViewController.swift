//
//  NewDestinationViewController.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/28/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class NewDestinationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let geoCoder = CLGeocoder()
    var dataController: DataController!
    
    var newDestinationName: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var imageData: Data? = nil
    
    var photos = [Photo]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageData = nil
        destinationTextField.placeholder = "Where are you traveling to?"
        collectionView.dataSource = self
        collectionView.delegate = self
        configureFlowLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        geocodeDestination { (success) in
            if success {
                let newDestination = Destination(context: self.dataController.viewContext)
                newDestination.name = self.newDestinationName
                newDestination.latitude = self.latitude!
                newDestination.longitude = self.longitude!
                newDestination.image = self.imageData
                try? self.dataController.viewContext.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pickImage(_ sender: UIButton) {
        view.endEditing(true)
        if photos.isEmpty {
            geocodeDestination { (success) in
                if success {
                    FlickrClient.shared.getPhotos(latitude: self.latitude!, longitude: self.longitude!, text: self.newDestinationName!) { (result) in
                        if case let .success(parsedPhotos) = result {
                            self.photos = parsedPhotos
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func configureFlowLayout() {
        let space: CGFloat = 3.0
        var numberOfColumns: CGFloat = 3
        if view.frame.size.width > view.frame.size.height {
            numberOfColumns = 5.0
        }
        let dimension = (view.frame.size.width - ((numberOfColumns - 1) * space)) / numberOfColumns
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func geocodeDestination(completionHandler: @escaping (Bool) -> Void) {
        guard let newDestinationName = destinationTextField.text, destinationTextField.text != "" else {
            completionHandler(false)
            return
        }
        self.geoCoder.geocodeAddressString(newDestinationName) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                completionHandler(false)
                return
            }
            self.newDestinationName = newDestinationName
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            completionHandler(true)
        }
    }
    
    // MARK: - CollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
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
        imageData = photos[indexPath.item].imageData
    }
}
