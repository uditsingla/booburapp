//
//  DescriptionCell.swift
//  AdForest
//
//  Created by apple on 3/19/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
   
    @IBOutlet weak var lblNames: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblHtmlText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
