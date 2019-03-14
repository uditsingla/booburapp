//
//  Splash.swift
//  Adforest
//
//  Created by apple on 3/7/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class Splash: UIViewController, NVActivityIndicatorViewable {

  
    
    //MARK:- Properties
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsdata()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_checkLogin() {
        if defaults.bool(forKey: "isLogin") {
            guard let email = defaults.string(forKey: "email") else {
                return
            }
            guard let password = defaults.string(forKey: "password") else {
                return
            }
            if defaults.bool(forKey: "isSocial") {
                let param: [String: Any] = [
                    "email": email,
                    "type": "social"
                ]
                print(param)
                self.adForest_loginUser(parameters: param as NSDictionary)
            }
            else {
                let param : [String : Any] = [
                    "email" : email,
                    "password": password
                ]
                print(param)
                self.adForest_loginUser(parameters: param as NSDictionary)
            }
        }
        else {
            self.appDelegate.moveToLogin()
        }
    }
    
    //MARK:- API Call
    
    func settingsdata() {
        self.showLoader()
        UserHandler.settingsdata(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                //Change App Color Here
                self.defaults.set(successResponse.data.mainColor, forKey: "mainColor")
                self.appDelegate.customizeNavigationBar(barTintColor: Constants.hexStringToUIColor(hex: successResponse.data.mainColor))
                
                self.defaults.set(successResponse.data.isRtl, forKey: "isRtl")
                self.defaults.set(successResponse.data.notLoginMsg, forKey: "notLogin")
                self.defaults.synchronize()
                UserHandler.sharedInstance.objSettings = successResponse.data
                print(successResponse.data.menu.submenu.pages)
                print("hello3")
                UserHandler.sharedInstance.objSettingsMenu = successResponse.data.menu.submenu.pages
                if successResponse.data.isRtl {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                     self.adForest_checkLogin()
                }else {
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                     self.adForest_checkLogin()
                }
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
    
    // Login User
    func adForest_loginUser(parameters: NSDictionary) {
        self.showLoader()
        UserHandler.loginUser(parameter: parameters , success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.defaults.set(true, forKey: "isLogin")
                self.defaults.synchronize()
                self.appDelegate.moveToHome()
            }
            else {
                self.appDelegate.moveToLogin()
            }
        }) { (error) in
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
}
