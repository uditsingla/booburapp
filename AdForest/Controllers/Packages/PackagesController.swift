//
//  PackagesController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import DropDown
import NVActivityIndicatorView
import StoreKit
import SwiftyStoreKit
import GoogleMobileAds

protocol PaymentTypeDelegate {
    func paymentMethod(methodName: String, inAppID: String, packageID: String)
}

class PackagesController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, PaymentTypeDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
  
    //MARK:- Outlets
    @IBOutlet weak var lblNoData: UILabel!{
        didSet {
            lblNoData.isHidden = true
        }
    }
    @IBOutlet weak var oltAdPost: UIButton! {
        didSet {
            oltAdPost.circularButton()
            if let bgColor = defaults.string(forKey: "mainColor") {
                oltAdPost.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    //MARK:- Properties
    let addData = UserHandler.sharedInstance.objAdMob
    let defaults = UserDefaults.standard
    var dataArray = [PackagesDataProduct]()
    var isAppOpen = false
    var inAppSecretKey = ""
    var inApp_id = ""
    var package_id = ""
    var interstitial: GADInterstitial?
    
    //MARK:- Application Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarButtonWithImage(UIImage(named: "menu")!)
        self.googleAnalytics(controllerName: "Packages Controller")
        if defaults.bool(forKey: "isLogin") == false {
            self.oltAdPost.isHidden = true
        }
       self.adMob()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adForest_pakcagesData()
//        interstitial?.delegate = self
//        interstitial = self.appDelegate.createAndLoadInterstitial()
//        self.appDelegate.interstitial?.delegate = self
//        self.appDelegate.interstitial = self.appDelegate.createAndLoadInterstitial()
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
//    func createAndLoadInterstitial() -> GADInterstitial? {
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3521346996890484/7679081330")
//        guard let interstitial = interstitial else {
//            return nil
//        }
//        let request = GADRequest()
//        interstitial.delegate = self
//        interstitial.load(request)
//        return interstitial
//    }
    
//    func adMobSetup() {
//        self.appDelegate.adBannerView.delegate = self
//        self.appDelegate.adBannerView.rootViewController = self
//        self.appDelegate.adBannerView.load(GADRequest())
//    }
//
//    //MARK:- AdMob Delegates
//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
//        bannerView.transform = translateTransform
//        UIView.animate(withDuration: 0.5) {
//            bannerView.transform = CGAffineTransform.identity
//        }
//    }
//
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print("Fail to receive ads")
//        print(error)
//    }
//
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//        ad.present(fromRootViewController: self)
//    }
//
//    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
//        print("Fail to receive interstitial")
//    }
    
    func adMob() {
        if UserHandler.sharedInstance.objAdMob != nil {
            let objData = UserHandler.sharedInstance.objAdMob
            var isShowAd = false
            if let adShow = objData?.show {
                isShowAd = adShow
            }
            if isShowAd {
                var isShowBanner = false
                var isShowInterstital = false
                
                if let banner = objData?.isShowBanner {
                    isShowBanner = banner
                }
                if let intersitial = objData?.isShowInitial {
                    isShowInterstital = intersitial
                }
                if isShowBanner {
                    SwiftyAd.shared.setup(withBannerID: (objData?.bannerId)!, interstitialID: "", rewardedVideoID: "")
                     self.tableView.translatesAutoresizingMaskIntoConstraints = false
                    if objData?.position == "top" {
                        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40).isActive = true
                        SwiftyAd.shared.showBanner(from: self, at: .top)
                    }
                    else {
                        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 50).isActive = true
                        SwiftyAd.shared.showBanner(from: self, at: .bottom)
                    }
                }
                if isShowInterstital {
                    SwiftyAd.shared.setup(withBannerID: "", interstitialID: (objData?.interstitalId)!, rewardedVideoID: "")
                    SwiftyAd.shared.showInterstitial(from: self)
                }
            }
        }
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackagesCell", for: indexPath) as! PackagesCell
        
        let objData = dataArray[indexPath.row]
        let paymentData = UserHandler.sharedInstance.objPaymentType
        
        if let name = objData.productTitle {
            cell.lblOfferName.text = name
        }
        if let price = objData.productPrice {
            cell.lblPrice.text = price
        }
        if let mainColor = defaults.string(forKey: "mainColor") {
            cell.lblPrice.textColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        if let validityText = objData.daysText {
            if let daysvalue = objData.daysValue {
                cell.lblValidity.text = "\(validityText): \(daysvalue)"
            }
        }
        if let freeAdsText = objData.freeAdsText {
            if let freeAdsValue = objData.freeAdsValue {
                cell.lblFreeAds.text = "\(freeAdsText): \(freeAdsValue)"
            }
        }
        if let fearureAdsText = objData.featuredAdsText {
            if let featureAdValue = objData.featuredAdsValue {
                cell.lblFeaturedAds.text = "\(fearureAdsText): \(featureAdValue)"
            }
        }
        if let bumpUptext = objData.bumpAdsText {
            if let bumpValue = objData.bumpAdsValue {
                cell.lblBumpUpAds.text = "\(bumpUptext): \(bumpValue)"
            }
        }
        if let paymentTypeButton = objData.paymentTypesValue {
            cell.buttonSelectOption.setTitle(paymentTypeButton, for: .normal)
        }
        cell.package_id = objData.productId
        cell.dropShow = { () in
            if self.defaults.bool(forKey: "isLogin") == false {
                if let msg = self.defaults.string(forKey: "notLogin") {
                    let alert = Constants.showBasicAlert(message: msg)
                    self.presentVC(alert)
                }
            } else {
                cell.dropDownValueArray = []
                if (paymentData?.paymentTypes.isEmpty)! {
                } else {
                    for items in (paymentData?.paymentTypes)! {
                        if items.key == "" {
                            continue
                        }
                        cell.dropDownValueArray.append(items.value)
                        cell.dropDownKeyArray.append(items.key)
                    }
                    if self.isAppOpen {
                        cell.selectedInAppPackage = objData.productAppCode.ios
                    }
                    cell.delegate = self
                    cell.selectCategory()
                    cell.categoryDropDown.show()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return self.appDelegate.adBannerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.appDelegate.adBannerView.frame.height
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    
    //MARK:- Change Status delegate
    func paymentMethod(methodName: String, inAppID: String, packageID: String) {
         if methodName == "app_inapp" {
            self.inApp_id = inAppID
            self.package_id = packageID
            self.adForest_MoveToInAppPurchases()
        } else {
            print("Not Found")
        }
    }
    
    //MARK:- In App Method
    func adForest_MoveToInAppPurchases() {
        self.purchaseProduct(productID: self.inApp_id)
    }
    
    func getInfo() {
        self.showNavigationActivity()
        SwiftyStoreKit.retrieveProductsInfo([inApp_id], completion: {
            result in
            self.hideNavigationActivity()
            self.showAlert(alert: self.alertForProductRetrivalInfo(result: result))
        })
    }
    
    func purchaseProduct(productID: String) {
        self.showNavigationActivity()
        SwiftyStoreKit.purchaseProduct(inApp_id, completion: {
            result in
            self.hideNavigationActivity()
            if case .success(let product) = result {
                let parameters: [String: Any] = [
                    "package_id": self.package_id,
                    "payment_from": "app_inapp"
                ]
                print(parameters)
                self.adForest_paymentConfirmation(parameter: parameters as NSDictionary)
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
               // self.showAlert(alert: self.alertForPurchasedResult(result: result))
            }
        })
    }

    func restorePurchase() {
        self.showNavigationActivity()
        SwiftyStoreKit.restorePurchases(atomically: true,  completion: {
            result in
            self.hideNavigationActivity()
            for product in result.restoredPurchases {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.showAlert(alert: self.alertForRestorePurchase(result: result))
        })
    }
    
    func verifyReceipt() {
        self.showNavigationActivity()
        let validator = AppleReceiptValidator(service: .production, sharedSecret: inAppSecretKey)
        SwiftyStoreKit.verifyReceipt(using: validator, completion: {
            result in
            self.hideNavigationActivity()
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            
            if case .error(let error)  = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    
    func verifyPurchase() {
        self.showNavigationActivity()
        let validator = AppleReceiptValidator(service: .production, sharedSecret: inAppSecretKey)
        SwiftyStoreKit.verifyReceipt(using: validator, completion: {
            result in
            self.hideNavigationActivity()
            switch result {
            case .success(let receipt):
                let productID = self.inApp_id
                let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                self.showAlert(alert: self.alertForVerifyPurchase(result: purchaseResult))
            case .error(let error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    
    func refreshReceipt() {
        let validator = AppleReceiptValidator(service: .production, sharedSecret: inAppSecretKey)
        SwiftyStoreKit.verifyReceipt(using: validator, completion: {
            result in
            self.showAlert(alert: self.alertForRefreshReceipt(result: result))
        })
    }
 
    //MARK:- IBActions
    @IBAction func actionAdPost(_ sender: Any) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    
    //MARK:- API Call
    func adForest_pakcagesData() {
        self.showLoader()
        UserHandler.packagesdata(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.extra.pageTitle
                self.dataArray = successResponse.data.products
                UserHandler.sharedInstance.objPaymentType = successResponse.data
                if let isApp = successResponse.extra.ios.inAppOn {
                    self.isAppOpen = isApp
                }
                if self.isAppOpen {
                    if let secretKey = successResponse.extra.ios.secretCode {
                        self.inAppSecretKey = secretKey
                    }
                }
                self.tableView.reloadData()
            }
            else {
                self.lblNoData.isHidden = false
                self.lblNoData.text = successResponse.message
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


extension PackagesController {
    func alertWithTitle(title: String, message: String)-> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrivalInfo(result: RetrieveResults)-> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        }
        else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: "Could Not retrieve Info", message: "Invalid Product ID: \(invalidProductID)")
        }
        else {
            let errorString = result.error?.localizedDescription ?? "Unknown Error. Please Contact Support"
            return alertWithTitle(title: "Could not retrieve info", message: errorString)
        }
    }
    
    
    func alertForPurchasedResult(result: PurchaseResult)-> UIAlertController {
        
        switch result {
        case .success(let purchase):
             print("Purchase SuccessFfull: \(purchase.productId)")
             return alertWithTitle(title: "Thank You", message: "Purchase Completed")
        case .error(let error):
            return alertWithTitle(title: "Error", message: "\(error)")
        }
    }
    
    func alertForRestorePurchase(result: RestoreResults)-> UIAlertController {
        
        if result.restoredPurchases.count > 0 {
            print("restore Failed \(result.restoredPurchases)")
            return alertWithTitle(title: "Restore Failed", message: "Error. Please Contact Support")
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: "Purchase Restored", message: "All Purchases Have been restored")
        }
        else {
            return alertWithTitle(title: "Nothing to restore", message: "No previous purchases were made")
        }
    }
    
    
    func alertForVerifyReceipt(result: VerifyReceiptResult)-> UIAlertController {
        
        switch result {
        case .success( _):
            return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt Verification", message: "No receipt data found, application will try to get a new one. Try again")
            default:
                return alertWithTitle(title: "Receipt Verification", message: "Receipt Verification Failed.")
            }
        }
    }
    
    
    func alertForVerifySubscription(result: VerifySubscriptionResult)-> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Product is Purchased", message: "Product is valid until \(expiryDate)")
        case .notPurchased:
            return alertWithTitle(title: "Not Purchased", message: "This product has never been purchased")
        case .expired(let expiryDate):
            return alertWithTitle(title: "Product Expired", message: "Product is expire since \(expiryDate)")
        }
    }
    
    
    func alertForVerifyPurchase(result: VerifyPurchaseResult)-> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is purchased", message: "Product will not expire")
        case .notPurchased:
            return alertWithTitle(title: "Product not purchased", message: "Product has never been purchased")
        }
    }
    
    func alertForRefreshReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success( _):
            return alertWithTitle(title: "Receipt refresh", message: "receipt refresh successfully")
        case .error( _):
            return alertWithTitle(title: "Receipt refresh failed", message: "Receipt refresh failed")
        }
    }
}
