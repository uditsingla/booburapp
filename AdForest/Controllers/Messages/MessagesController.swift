//
//  MessagesController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SlideMenuControllerSwift
import NVActivityIndicatorView

class MessagesController: ButtonBarPagerTabStripViewController, NVActivityIndicatorViewable {

    //MARK:- Properties
    var menuDelegate: leftMenuProtocol?
    var isFromAdDetail = false
    let defaults = UserDefaults.standard
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        self.customizePagerTabStrip()
        super.viewDidLoad()
        if let messageTitle = defaults.string(forKey: "message") {
            self.title = messageTitle
        }
        self.googleAnalytics(controllerName: "Messages Controller")
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromAdDetail {
            self.showBackButton()
        } else {
             self.addBackButtonToNavigationBar()
        }
    }
    
    //MARK: - Custom
    
    
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func customizePagerTabStrip() {
        settings.style.buttonBarBackgroundColor = .white
        if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
            settings.style.buttonBarItemBackgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            settings.style.buttonBarItemTitleColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        settings.style.selectedBarBackgroundColor = .darkGray
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0.0
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else {return}
            oldCell?.label.textColor = .white
            newCell?.label.textColor = .white
        }
    }
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.menuDelegate?.changeViewController(.main)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let SB = UIStoryboard(name: "Main", bundle: nil)
        let sentOffers = SB.instantiateViewController(withIdentifier: "SentOffersController") as! SentOffersController
        let addsOffer = SB.instantiateViewController(withIdentifier: "OffersOnAdsController") as! OffersOnAdsController
        let childVC = [sentOffers, addsOffer]
        return childVC
    }
}
