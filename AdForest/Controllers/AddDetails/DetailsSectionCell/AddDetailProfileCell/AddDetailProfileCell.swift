//
//  AddDetailProfileCell.swift
//  AdForest
//
//  Created by apple on 4/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import Cosmos

class AddDetailProfileCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblLastLogin: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var ratingText: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var oltCoverButton: UIButton!
    @IBOutlet weak var oltBlockButton: UIButton!
    
    
    //MARK:- Properties
    var btnCoverAction : (()->())?
    var btnBlock: (()->())?
    
    
    //MARK:- View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func coverButtonAction(_ sender: Any) {
        self.btnCoverAction?()
    }
    
    @IBAction func actionDelete(_ sender: UIButton) {
        self.btnBlock?()
    }
    
}
