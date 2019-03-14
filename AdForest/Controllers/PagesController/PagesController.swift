//
//  PagesController.swift
//  AdForest
//
//  Created by apple on 6/1/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import WebKit

class PagesController: UITableViewController {

    
    var delegate :leftMenuProtocol?
    //var slug = 0
    //var page_id = 0
    //var title = 0
    //var post_id = 0
    //@IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBackButtonToNavigationBar()
        
        //print("hii8888")
        // print(slug)
        //print(page_id)
        //print(title)
        //print(post_id)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Pages Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        //self.present("vikram")
    }
    
    
    //MARK:- Custom
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
}
