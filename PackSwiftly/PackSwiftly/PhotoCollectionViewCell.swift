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
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.transform = .init(scaleX: 0.9, y: 0.9)
                    self.imageView.alpha = 0.5
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.transform = .identity
                    self.imageView.alpha = 1.0
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        confugire()
    }
    
    func update(with image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
    }
    
    private func confugire() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
}
