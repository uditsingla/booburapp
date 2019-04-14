//
//  HomeFeatureCollectionCell.swift
//  AdForest
//
//  Created by apple on 5/30/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class HomeFeatureCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel!{
        didSet{
            if let mainColor =  UserDefaults.standard.string(forKey: "mainColor"){
                lblPrice.textColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var lblFeatured: UILabel!
    
    
    var btnFullAction: (()->())?
    
    
    @IBAction func actionFullButton(_ sender: Any) {
        self.btnFullAction?()
    }
    
}
