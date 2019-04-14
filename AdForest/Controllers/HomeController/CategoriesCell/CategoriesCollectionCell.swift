//
//  CategoriesCollectionCell.swift
//  AdForest
//
//  Created by apple on 4/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class CategoriesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var imgContainer: UIView! {
        didSet {
            imgContainer.layer.borderWidth = 0.5
            imgContainer.layer.borderColor = UIColor.darkGray.cgColor
        }
    }
    
    var btnFullAction: (()->())?
    
    
    @IBAction func actionFullButton(_ sender: Any) {
        self.btnFullAction?()
    }
    
}
