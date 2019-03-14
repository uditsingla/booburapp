//
//  RatingReviewsController.swift
//  AdForest
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class RatingReviewsController: UIViewController {

    
    @IBOutlet weak var scrollBar: UIScrollView!
    @IBOutlet weak var imgContainer: UIView! {
        didSet {
            imgContainer.circularView()
        }
    }
    
    @IBOutlet weak var imgPicture: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var oltLoadMore: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Rating Reviews Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    @IBAction func actionLoadMore(_ sender: Any) {
        
    }
    
}
