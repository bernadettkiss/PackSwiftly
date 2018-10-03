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
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var destinationNameLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    
    static let reuseIdentifier = "tripTableViewCell"
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            transparentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7042487158)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            transparentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7042487158)
        }
    }
    
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
