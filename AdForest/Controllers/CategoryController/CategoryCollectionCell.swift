//
//  CategoryCollectionCell.swift
//  AdForest
//
//  Created by apple on 4/18/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblFeature: UILabel!
    
}
