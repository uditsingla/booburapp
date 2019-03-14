//
//  StripePaymentController.swift
//  AdForest
//
//  Created by apple on 4/5/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Stripe

class StripePaymentController: UIViewController, NVActivityIndicatorViewable, STPPaymentCardTextFieldDelegate , MoveToPackagesDelegate {
   
    //MARK:- Outlets
    @IBOutlet weak var oltCheckOut: UIButton! {
        didSet {
            oltCheckOut.isHidden = true
            oltCheckOut.roundCornors()
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltCheckOut.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    //MARK:- Properties

    var method = ""
    var package_id = ""
    let payCardTextField = STPPaymentCardTextField()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.hideKeyboard()
        self.paymentTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Stripe Payment Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    
        self.adForest_checkOutData()
    }

   
    
    func paymentTextField() {
        payCardTextField.frame = CGRect(x: 20, y: 30, width: self.view.frame.width - 40, height: 40)
        payCardTextField.delegate = self
        self.view.addSubview(payCardTextField)
    }
    
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid {
            oltCheckOut.isHidden = false
        }
        else {
             oltCheckOut.isHidden = true
        }
    }
    
    //MARK:- Delegate To Root
    func moveToRoot(isMove: Bool) {
        if isMove {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if UserHandler.sharedInstance.objStripeData != nil {
            let objData = UserHandler.sharedInstance.objStripeData
          
            self.title = objData?.pageTitle
            
            if let checkoutText = objData?.form.btnText {
                self.oltCheckOut.setTitle(checkoutText, for: .normal)
            }
        }
        else {
            print("Data Nil")
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func actionCheckOut(_ sender: UIButton) {

      let cardParms = payCardTextField.cardParams
        
        STPAPIClient.shared().createToken(withCard: cardParms) { (token, error) in
            if let error = error {
                print(error)
            }
            else if let token = token {
                print(token)
                let params: [String: Any] = [
                    "package_id" : self.package_id,
                    "payment_from": self.method.lowercased(),
                    "source_token": token.tokenId
                ]
                print(params)
                self.adForest_paymentConfirmation(parameter: params as NSDictionary)
            }
        }
    }

    //MARK:- API Call
    
    func adForest_checkOutData() {
        self.showLoader()
        UserHandler.stripeCheckOutData(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                UserHandler.sharedInstance.objStripeData = successResponse.data
                self.adForest_populateData()
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
    
    // payment confirmation
    func adForest_paymentConfirmation(parameter: NSDictionary) {
        self.showLoader()
        UserHandler.paymentConfirmation(parameters: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let paymentSuccessVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentSuccessController") as! PaymentSuccessController
                paymentSuccessVC.delegate = self
                self.presentVC(paymentSuccessVC)
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
