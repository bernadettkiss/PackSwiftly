//
//  TripTableViewCell.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/7/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {
    
    @IBOutlet weak var destinationImageView: UIImageView!
    @IBOutlet weak var destinationNameLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    
    func update(withImage image: UIImage?, text: String, startDate: Date, endDate: Date) {
        if let image = image {
            destinationImageView.image = image
            destinationImageView.contentMode = .scaleAspectFill
        } else {
            destinationImageView.image = nil
        }
        destinationNameLabel.text = text
        tripDatesLabel.text = "\(format(date: startDate)) - \(format(date: endDate))"
    }
    
    private func format(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
