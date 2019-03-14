//
//  ShareCell.swift
//  AdForest
//
//  Created by apple on 3/19/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class ShareCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgDate: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var imgLookAdd: UIImageView!
    @IBOutlet weak var lblLookAdd: UILabel!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var containerViewButton: UIView!
    @IBOutlet weak var buttonShare: UIButton!{
        didSet{
            buttonShare.layer.borderWidth = 0.5
            buttonShare.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var buttonFavourite: UIButton! {
        didSet {
            buttonFavourite.titleLabel?.minimumScaleFactor = 0.5
            buttonFavourite.titleLabel?.numberOfLines = 0
            buttonFavourite.titleLabel?.adjustsFontSizeToFitWidth = true
            buttonFavourite.layer.borderWidth = 0.5
            buttonFavourite.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var buttonReport: UIButton! {
        didSet{
            buttonReport.layer.borderWidth = 0.5
            buttonReport.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    
    //MARK:- Properties
    
    var btnFavouriteAdd: (()->())?
    var btnReport: (()->())?
    var btnShare: (()->())?
    
    //MARK:- View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func actionShare(_ sender: Any) {
        self.btnShare?()
        print("Share")
    }
    
    @IBAction func actionFavourite(_ sender: Any) {
        self.btnFavouriteAdd?()
        print("Favourite")
    }
    
    @IBAction func actionReport(_ sender: Any) {
        self.btnReport?()
        print("Report")
    }
    
    
    
}
