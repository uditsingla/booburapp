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

class NetworkActivityIndicatorManager : NSObject {
    private static var loadingCount = 0
    
    class func networkOperationStart() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    
    class func networkOperationFinish() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}

protocol PaymentTypeDelegate {
    func paymentMethod(methodName: String, price: String, packagePlan: String, package_id : String, inAppID: String)
}

class PackagesController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, PayPalPaymentDelegate ,PaymentTypeDelegate {
  
    //MARK:- Outlets
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
            tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //MARK:- Properties
    var defaults = UserDefaults.standard
    var package_ID = ""
    var payPalPaymentArray = [String]()
    var dataArray = [PackagesDataProduct]()
    var isAppOpen = false
    var inAppSecretKey = ""
    var inApp_id = ""
   // var bundleID = ""
    //PayPay SetUp
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration() // default
    var paypalParameters = [String: Any]()
    
    //MARK:- Application Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adForest_pakcagesData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Packages Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        
        if defaults.bool(forKey: "isRtl") {
            self.addRightBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
        else {
            self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //Convert data to json string
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    
    //paypal configuration
    func adForest_payPalConfig() {
        if UserHandler.sharedInstance.objPayPal != nil {
            let objPayPal = UserHandler.sharedInstance.objPayPal
            
            //Initialize PayPal Setting
            
            if objPayPal?.mode == "sandbox" {
                 PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox: objPayPal?.apiKey])
            }
            else {
                 PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: objPayPal?.apiKey])
            }
            PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentSandbox)
    
            // Set up payPalConfig
            
            payPalConfig.acceptCreditCards = false
            payPalConfig.merchantName = objPayPal?.merchantName
            payPalConfig.merchantPrivacyPolicyURL = URL(string: (objPayPal?.privecyUrl)!)
            payPalConfig.merchantUserAgreementURL = URL(string: (objPayPal?.agreementUrl)!)
            payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
            payPalConfig.payPalShippingAddressOption = .payPal
        }
        else {
            print("No PayPal Data")
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
        let cell : PackagesCell = tableView.dequeueReusableCell(withIdentifier: "PackagesCell", for: indexPath) as! PackagesCell
        
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
        
        //Sent to cell class to set price and package name
        cell.payPalyPrice = objData.productAmount.value
        cell.selectionProductTitle = objData.productTitle
        cell.packageId = objData.productId
        
        if defaults.bool(forKey: "isGuest") {
            cell.viewButton.isHidden = true
        }
         
        else {
            cell.viewButton.isHidden = false
            cell.dropShow = { () in
                cell.dropDownValueArray = []
                if (paymentData?.paymentTypes.isEmpty)! {
                }
                else {
                    for items in (paymentData?.paymentTypes)! {
                        cell.dropDownValueArray.append(items.value)
                        cell.dropDownKeyArray.append(items.key)
                    }
                    if self.isAppOpen {
                     cell.selectedInAppPackage = objData.productAppCode.ios
                    }
                    cell.selectCategory()
                    cell.categoryDropDown.show()
                    cell.delegate = self
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
        if defaults.bool(forKey: "isGuest") {
            return 140
        }
        return 205
    }
    
    //MARK:- Change Status delegate
    func paymentMethod(methodName: String, price: String, packagePlan: String, package_id: String, inAppID: String) {
        print(inAppID)
        if methodName == "paypal" {
            self.adForest_MoveToPaypal(price: price, packagePlan: packagePlan, packageID: package_id)
        }
        else if methodName == "cheque" {
            self.adForest_paymentByCheque(methodName: methodName, package_id: package_id)
        }
        else if methodName == "bank_transfer" {
            self.adForest_bankTransfer(methodName: methodName, package_id: package_id)
        }
        else if methodName == "cash_on_delivery" {
            self.adForest_cashOnDelivery(methodName: methodName, package_id: package_id)
        }
        else if methodName == "stripe" {
            self.adForest_paymentByStripe(methodName: methodName, package_id: package_id)
        }
        else if methodName == "app_inapp" {
            print("In App Method")
            self.inApp_id = inAppID
            self.adForest_MoveToInAppPurchases()
        }
        else {
            print("Not Found")
        }
    }
   
    func adForest_paymentByStripe(methodName: String, package_id: String) {
        let checkOutStripeVC =  self.storyboard?.instantiateViewController(withIdentifier: "StripePaymentController") as! StripePaymentController
        checkOutStripeVC.method = methodName
        checkOutStripeVC.package_id = package_id
        self.navigationController?.pushViewController(checkOutStripeVC, animated: true)
    }
    
    func adForest_cashOnDelivery(methodName: String, package_id: String) {
        let parameters: [String: Any] = [
            "package_id": package_id,
            "payment_from": methodName
        ]
        print(parameters)
        self.adForest_paymentConfirmation(parameter: parameters as NSDictionary)
    }
    
    func adForest_bankTransfer(methodName: String, package_id: String) {
        let parameters: [String: Any] = [
            "package_id": package_id,
            "payment_from": methodName
        ]
        print(parameters)
        self.adForest_paymentConfirmation(parameter: parameters as NSDictionary)
    }
    
    func adForest_paymentByCheque(methodName: String, package_id: String) {
        let parameters: [String: Any] = [
            "package_id": package_id,
            "payment_from": methodName
        ]
        print(parameters)
        self.adForest_paymentConfirmation(parameter: parameters as NSDictionary)
    }
    //MARK:- In App Method
    func adForest_MoveToInAppPurchases() {
        self.purchaseProduct(productID: self.inApp_id)
    }
    
    func getInfo() {
        NetworkActivityIndicatorManager.networkOperationStart()
        SwiftyStoreKit.retrieveProductsInfo([inApp_id], completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinish()
            self.showAlert(alert: self.alertForProductRetrivalInfo(result: result))
        })
    }
    
    func purchaseProduct(productID: String) {
        NetworkActivityIndicatorManager.networkOperationStart()
        SwiftyStoreKit.purchaseProduct(inApp_id, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinish()
            
            if case .success(let product) = result {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.showAlert(alert: self.alertForPurchasedResult(result: result))
            }
        })
    }


    func restorePurchase() {
        NetworkActivityIndicatorManager.networkOperationStart()
        SwiftyStoreKit.restorePurchases(atomically: true,  completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinish()
            for product in result.restoredPurchases {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            self.showAlert(alert: self.alertForRestorePurchase(result: result))
            
        })
    }
    
    func verifyReceipt() {
        NetworkActivityIndicatorManager.networkOperationStart()
        let validator = AppleReceiptValidator(service: .production, sharedSecret: inAppSecretKey)
        SwiftyStoreKit.verifyReceipt(using: validator, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinish()
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            
            if case .error(let error)  = result {
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        })
    }
    
    
    func verifyPurchase() {
        NetworkActivityIndicatorManager.networkOperationStart()
        let validator = AppleReceiptValidator(service: .production, sharedSecret: inAppSecretKey)
        SwiftyStoreKit.verifyReceipt(using: validator, completion: {
            result in
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
    
    //MARK:- Paypal Method
    func adForest_MoveToPaypal(price: String, packagePlan: String, packageID: String) {
        self.package_ID = packageID
        var currencyName = ""
        if let currencyTitle = UserHandler.sharedInstance.objPayPal?.currency {
            currencyName = currencyTitle
        }
        let decimalPrice = NSDecimalNumber(string: price)
        let item = PayPalItem(name: packagePlan, withQuantity: 1, withPrice: decimalPrice, withCurrency: currencyName, withSku: nil)
        let items = [item]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        
        let shipping = NSDecimalNumber(string: "0.0")
        let tax = NSDecimalNumber(string: "0.0")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        //let total = subtotal.adding(shipping).adding(tax)

        let payment = PayPalPayment(amount: subtotal, currencyCode: currencyName, shortDescription: packagePlan, intent: .sale)
        
        let amountInString = String(describing: payment.amount)
       //parameters to send in final server call
        paypalParameters = ["amount": amountInString, "currency_code": payment.currencyCode, "short_description": payment.shortDescription, "intent": "sale"]
       
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            print("Payment not processalbe: \(payment)")
        }
    }

    // PayPal Payment Delegate Methods
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
     
            let resultDictionary = completedPayment.confirmation as NSDictionary
            
            let response: AnyObject  = resultDictionary.object(forKey: "response") as AnyObject
          
            let payPalToken = response.object(forKey: "id")
            
            let paymentClient  = self.json(from: self.paypalParameters)
            let param: [String: Any] = [
                "package_id": self.package_ID,
                "source_token": payPalToken!,
                "payment_from": "paypal",
                "payment_client": paymentClient!
            ]
            print(param)
            self.adForest_paymentConfirmation(parameter: param as NSDictionary)
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
                UserHandler.sharedInstance.objPayPal = successResponse.data.paypal
            
                if let isApp = successResponse.extra.ios.inAppOn {
                    self.isAppOpen = isApp
                }
                
                if self.isAppOpen {
                    if let secretKey = successResponse.extra.ios.secretCode {
                        self.inAppSecretKey = secretKey
                    }
                }
                
                self.adForest_payPalConfig()
                self.tableView.reloadData()
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
            print(successResponse)
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
        case .success(let receipt):
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
        case .success(let receiptData):
            return alertWithTitle(title: "Receipt refresh", message: "receipt refresh successfully")
        case .error(let error):
            return alertWithTitle(title: "Receipt refresh failed", message: "Receipt refresh failed")
        }
    }
}



//MARK:- Package Cell Class

class PackagesCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var lblOfferName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var lblValidity: UILabel!
    @IBOutlet weak var lblFreeAds: UILabel!
    @IBOutlet weak var lblFeaturedAds: UILabel!
    @IBOutlet weak var lblBumpUpAds: UILabel!
    @IBOutlet weak var viewButton: UIView! {
        didSet {
            viewButton.layer.borderWidth = 0.5
            viewButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var buttonSelectOption: UIButton! {
        didSet {
            buttonSelectOption.contentHorizontalAlignment = .left
        }
    }
    
    //MARK:- Properties
    var delegate : PaymentTypeDelegate?
    let categoryDropDown = DropDown()
    
    lazy var dropDown : [DropDown] = {
        return [
            self.categoryDropDown
        ]
    }()
    
    var dropShow: (()->())?
    var dropDownValueArray = [String]()
    var dropDownKeyArray = [String]()
    
    
    var defaults = UserDefaults.standard
    var settingObject = [String: Any]()
    var popUpMsg = ""
    var popUpText = ""
    var popUpCancelButton = ""
    var popUpOkButton = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var payPalyPrice = ""
    var selectionProductTitle = ""
    var packageId = ""
    var selectedInAppPackage = ""
   
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.adForest_settingsData()
    }
    
    //MARK:- Custom
    
    func selectCategory() {
        categoryDropDown.anchorView = buttonSelectOption
        categoryDropDown.dataSource = dropDownValueArray
        categoryDropDown.selectionAction = { [unowned self] (index, item) in
            self.buttonSelectOption.setTitle(item, for: .normal)
            
            print("\(self.payPalyPrice), \(self.selectionProductTitle)")
            let cashTypeKey = self.dropDownKeyArray[index]
            //send data to main class to send to server in alert controller action
            let alert = UIAlertController(title: self.popUpMsg, message: self.popUpText, preferredStyle: .alert)
            let okAction = UIAlertAction(title: self.popUpOkButton, style: .default, handler: { (okAction) in
                self.delegate?.paymentMethod(methodName: cashTypeKey, price: self.payPalyPrice, packagePlan: self.selectionProductTitle, package_id: self.packageId, inAppID: self.selectedInAppPackage)
            })
            let cancelAction = UIAlertAction(title: self.popUpCancelButton, style: .default, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.appDelegate.presentController(ShowVC: alert)
        }
    }
   
    func adForest_settingsData() {
        if let settingsInfo = defaults.object(forKey: "settings") {
            settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]

            let model = SettingsRoot(fromDictionary: settingObject)
         
            if let dialogMSg = model.data.dialog.confirmation.title {
                self.popUpMsg = dialogMSg
            }
            if let dialogText = model.data.dialog.confirmation.text {
                self.popUpText = dialogText
            }
            if let cancelText = model.data.dialog.confirmation.btnNo {
                self.popUpCancelButton = cancelText
            }
            if let confirmText = model.data.dialog.confirmation.btnOk {
                self.popUpOkButton = confirmText
            }
        }
    }
    
    //MARK:- IBActions
    @IBAction func actionSelectOption(_ sender: Any) {
        dropShow?()
    }
}

