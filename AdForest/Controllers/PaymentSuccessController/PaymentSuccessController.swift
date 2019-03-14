//
//  PaymentSuccessController.swift
//  AdForest
//
//  Created by apple on 4/5/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol MoveToPackagesDelegate {
    func moveToRoot(isMove: Bool)
}

class PaymentSuccessController: UIViewController , UIScrollViewDelegate, NVActivityIndicatorViewable, UIWebViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var scrollBar: UIScrollView! {
        didSet {
            scrollBar.delegate = self
            scrollBar.isScrollEnabled = true
            scrollBar.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblResponse: UILabel!
    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
            webView.isOpaque = false
            webView.backgroundColor = UIColor.white
        }
    }
   // @IBOutlet weak var buttonContinue: UIButton!
    
    //MARK:- Properties
    var delegate: MoveToPackagesDelegate?
    var dataArray = [PaymentSuccessData]()
    
    
    //MARK:- View Life Cycle
    
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
        tracker?.set(kGAIScreenName, value: "Payment Success Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        
        self.adForest_paymentSuccessData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrollBar.contentSize = CGSize(width: self.view.frame.width, height: 1200)
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if dataArray.isEmpty {
            
        }
        else {
            for items in dataArray {
                if let responseText = items.orderThankyouTitle {
                    self.lblResponse.text = responseText
                }
//                if let buttonText = items.orderThankyouBtn {
//                    self.buttonContinue.setTitle(buttonText, for: .normal)
//                }
                if let webViewData = items.data {
                    self.webView.loadHTMLString(webViewData, baseURL: nil)
                }
            }
        }
    }
    
    //to set webview size with amount of data
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(.zero)
    }
    
    
    //MARK:- IBActions

    @IBAction func actionCancel(_ sender: UIButton) {
        self.dismissVC {
            self.delegate?.moveToRoot(isMove: true)
        }
    }
    
//    @IBAction func actionContinue(_ sender: Any) {
//        self.dismissVC(completion: nil)
//    }
    
    
    
    //MARK:- API Call
    func adForest_paymentSuccessData() {
        self.showLoader()
        UserHandler.paymentSuccess(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.dataArray = [successResponse.data]
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
    
}

