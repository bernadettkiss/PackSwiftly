//
//  PhotoCollectionViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/29/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func update(with image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }
}
