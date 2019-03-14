//
//  VerifyNumberController.swift
//  AdForest
//
//  Created by apple on 3/26/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class VerifyNumberController: UIViewController, NVActivityIndicatorViewable {

    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var viewMsg: UIView! {
        didSet {
            viewMsg.circularView()
        }
    }
    @IBOutlet weak var imgMsg: UIImageView!
    
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var buttonResend: UIButton!
    
    //MARK:- Properties
    var dataToShow = UserHandler.sharedInstance.objProfileDetails
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.adForest_populateData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Verify Number Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if dataToShow != nil {
            if let placeHolderText = dataToShow?.extraText.phoneDialog.textField {
                self.txtCode.placeholder = placeHolderText
            }
            if let cancelText = dataToShow?.extraText.phoneDialog.btnCancel {
                self.buttonCancel.setTitle(cancelText, for: .normal)
            }
            if let confirmText = dataToShow?.extraText.phoneDialog.btnConfirm {
                self.buttonOk.setTitle(confirmText, for: .normal)
            }
            if let resendText = dataToShow?.extraText.phoneDialog.btnResend {
                self.buttonResend.setTitle(resendText, for: .normal)
            }
        }
        else {
            
        }
    }

  
    //MARK:- IBActions
    @IBAction func actionCancel(_ sender: UIButton) {
        self.dismissVC(completion: nil)
    }
    
    @IBAction func actionOk(_ sender: UIButton) {
        guard let codeField = txtCode.text else {
            return
        }
        if codeField == "" {
            
        }
        
        else {
            let parameter : [String: Any] = ["verify_code": codeField]
            print(parameter)
            self.adForest_verifyCode(parameter: parameter as NSDictionary)
        }
        
    }

    @IBAction func actionResend(_ sender: UIButton) {
        self.adForest_phoneNumberVerify()
    }
    
    //MARK:- API Call
    
    func adForest_verifyCode(parameter: NSDictionary) {
        self.showLoader()
        UserHandler.verifyCode(param: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
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
    
    //send code
    
    func adForest_phoneNumberVerify() {
        self.showLoader()
        UserHandler.verifyPhone(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }

}







