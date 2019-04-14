//
//  AddsCollectionCell.swift
//  AdForest
//
//  Created by apple on 4/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class AddsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel! {
        didSet {
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
                lblPrice.textColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    //MARK:- Properties
    var btnFullAction: (()->())?
    
    //MARK:- IBActions
    @IBAction func actionFullButton(_ sender: Any) {
        self.btnFullAction?()
    }
    
    
}
