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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
            let keyboardStartFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardHeight = keyboardEndFrame.origin.y - keyboardStartFrame.origin.y
            
            UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: animationCurve), animations: {
                self.frame.origin.y += keyboardHeight
            }) { (true) in
                self.layoutIfNeeded()
            }
        }
    }
}
