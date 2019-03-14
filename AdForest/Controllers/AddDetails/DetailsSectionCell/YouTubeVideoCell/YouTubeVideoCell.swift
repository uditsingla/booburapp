//
//  YouTubeVideoCell.swift
//  AdForest
//
//  Created by apple on 4/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouTubeVideoCell: UITableViewCell {

    
    @IBOutlet weak var playerView: YouTubePlayerView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
