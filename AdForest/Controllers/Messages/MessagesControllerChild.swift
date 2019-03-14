//
//  MessagesControllerChild.swift
//  AdForest
//
//  Created by apple on 3/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class MessagesControllerChild: ButtonBarPagerTabStripViewController, NVActivityIndicatorViewable {

    override func viewDidLoad() {
     //   self.customizePagerTabStrip()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.adForest_sentOffersData()
    }

    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    
    func customizePagerTabStrip() {
        settings.style.buttonBarBackgroundColor = .white
        if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
        settings.style.buttonBarItemBackgroundColor = Constants.hexStringToUIColor(hex: mainColor)
        settings.style.buttonBarItemTitleColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0.0
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .white
            newCell?.label.textColor = .white
        }
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let SB = UIStoryboard(name: "Main", bundle: nil)
        //        let addsOffer = SB.instantiateViewController(withIdentifier: "OffersOnAdsController") as! OffersOnAdsController

        let sentOffers = SB.instantiateViewController(withIdentifier: "SentOffersController") as! SentOffersController

        let childVC = [sentOffers]
        return childVC
    }
}



extension MessagesControllerChild {
    //MARK:- API Calls
    func adForest_sentOffersData() {
        self.showLoader()
        UserHandler.getSentOffersData(success: { (successResponse) in
            self.stopAnimating()
            print(successResponse)
            if successResponse.success {
                UserHandler.sharedInstance.messagesTitle = successResponse.data.title.main
                UserHandler.sharedInstance.sentOffersTitle = successResponse.data.title.sent
                UserHandler.sharedInstance.offerOnAdsTitle = successResponse.data.title.receive
                
                UserHandler.sharedInstance.objSentOffers = successResponse.data
                UserHandler.sharedInstance.sentOffersArray = successResponse.data.sentOffers.items
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.updateSentOffersData), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationName.updateMessageTitle) , object: nil)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
            
        }) { (error) in
            self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
}




