//
//  UnderlinedSegmentedControl.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/24/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

@IBDesignable
class UnderlinedSegmentedControl: UISegmentedControl {
    
    let lineView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    private func configure() {
        backgroundColor = .clear
        tintColor = .clear
        setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 16),
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], for: .normal)
        setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 17),
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)], for: .selected)
        translatesAutoresizingMaskIntoConstraints = false
        
        lineView.frame = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width / CGFloat(numberOfSegments), height: 5.0)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = #colorLiteral(red: 1, green: 0.662745098, blue: 0, alpha: 1)
        self.addSubview(lineView)
        
        addTarget(self, action: #selector(valueChange), for: .valueChanged)
    }
    
    @objc func valueChange() {
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = self.frame.width / CGFloat(self.numberOfSegments) * CGFloat(self.selectedSegmentIndex)
        }
    }
}
