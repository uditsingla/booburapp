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

class MessagesController: UIViewController,NVActivityIndicatorViewable {

    var delegate: leftMenuProtocol?
    var isFromAdDetail = false
    
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateMessageTitle), object: nil, queue: nil) { (notification) in
            self.title = UserHandler.sharedInstance.messagesTitle
        }
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.adForest_sentOffersData()

        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Messages Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        if isFromAdDetail {
            self.showBackButton()
        }
        else {
              self.addBackButtonToNavigationBar()
        }
    }
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
}
extension MessagesController {
    //MARK:- API Calls
    func adForest_sentOffersData() {
        self.showLoader()
        UserHandler.getSentOffersData(success: { (successResponse) in
            self.stopAnimating()
            print(successResponse)
            if successResponse.success {
                UserHandler.sharedInstance.messagesTitle = "Sent Messages"//successResponse.data.title.sent
              //  UserHandler.sharedInstance.sentOffersTitle = successResponse.data.title.sent
             //   UserHandler.sharedInstance.offerOnAdsTitle = successResponse.data.title.receive
                
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
