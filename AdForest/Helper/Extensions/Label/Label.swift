//
//  Label.swift
//  AdForest
//
//  Created by apple on 3/15/18.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func round(radius: CGFloat? = nil , bordorWidth: CGFloat? = nil , bordorColor: UIColor? = nil) {
        
        var cornor: CGFloat
        if let radius = radius {
            cornor = radius
        } else  {
            cornor = frame.height / 2
        }
        
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.cornerRadius = cornor
        layer.borderColor = UIColor.white.cgColor
        clipsToBounds = true
        
    }
}


extension UILabel {
    func underlineLabel() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
