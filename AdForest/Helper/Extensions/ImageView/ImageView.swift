//
//  ImageView.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func round(radius: CGFloat? = nil, borderWidth: CGFloat? = nil, bordorColor: UIColor? = nil) {
        
        var cornor: CGFloat
        
        if let radius = radius {
            cornor = radius
        } else {
            cornor = frame.height / 2
        }
        
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        //backgroundColor = UIColor.white
        layer.cornerRadius = cornor
        clipsToBounds = true
    }
    
    func roundWithClear(radius: CGFloat? = nil) {
        
        var cornor: CGFloat
        
        if let radius = radius {
            cornor = radius
        } else {
            cornor = frame.height / 2
        }
        
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear
        layer.cornerRadius = cornor
        clipsToBounds = true
    }
    
    func roundWithClearColor(radius: CGFloat? = nil) {
        
        var cornor: CGFloat
        
        if let radius = radius {
            cornor = radius
        } else {
            cornor = frame.height / 2
        }
        
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear
        layer.cornerRadius = cornor
        clipsToBounds = true
    }
}

extension UIImageView {
    func blur(style: UIBlurEffectStyle?) {
        
        var blurStyle: UIBlurEffectStyle
        
        if let style = style {
            blurStyle = style
        } else {
            blurStyle = .light
        }
        
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

extension UIImageView {
    func downloadImageFrom(link: String, contentMode: UIViewContentMode?) {
        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.image = UIImage(data: data)
                }
            }
        }).resume()
    }
}

extension UIImageView {
    func tintImageColor(color : UIColor) {
        self.image = self.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.tintColor = color
    }
}
