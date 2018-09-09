//
//  DestinationTableViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/7/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class DestinationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var destinationImage: UIImageView!
    @IBOutlet weak var destinationName: UILabel!
    
    func update(with image: UIImage?, and text: String) {
        if let image = image {
            destinationImage.image = image
            destinationImage.contentMode = .scaleAspectFill
        } else {
            destinationImage.image = nil
        }
        destinationName.text = text
    }
}
