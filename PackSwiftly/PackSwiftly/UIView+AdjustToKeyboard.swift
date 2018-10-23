//
//  UIView+AdjustToKeyboard.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 9/22/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import UIKit

extension UIView {
    
    func adjustToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            let keyboardStartFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardHeight = keyboardEndFrame.origin.y - keyboardStartFrame.origin.y
            
            UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: animationCurve), animations: {
                self.frame.origin.y += keyboardHeight
            }) { (true) in
                self.layoutIfNeeded()
            }
        }
    }
}
