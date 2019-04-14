//
//  RegisterViewController.swift
//  Adforest
//
//  Created by apple on 1/2/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import NVActivityIndicatorView

class RegisterViewController: UIViewController,UITextFieldDelegate, UIScrollViewDelegate, NVActivityIndicatorViewable, GIDSignInUIDelegate, GIDSignInDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var scrollBar: UIScrollView! {
        didSet {
            scrollBar.isScrollEnabled = false
        }
    }
    @IBOutlet weak var lblregisterWithUs: UILabel!
    @IBOutlet weak var txtName: UITextField! {
        didSet {
            txtName.delegate = self
        }
    }
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtEmail: UITextField! {
        didSet {
            txtEmail.delegate = self
        }
    }
    @IBOutlet weak var imgMsg: UIImageView!
    @IBOutlet weak var imgPhone: UIImageView!
    @IBOutlet weak var txtPhone: UITextField! {
        didSet {
            txtPhone.delegate = self
        }
    }
    @IBOutlet weak var imgPassword: UIImageView!
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            txtPassword.delegate = self
        }
    }
    @IBOutlet weak var buttonAgreeWithTermsConditions: UIButton! {
        didSet {
            buttonAgreeWithTermsConditions.contentHorizontalAlignment = .left
        }
    }
    @IBOutlet weak var buttonCheckBox: UIButton!
    @IBOutlet weak var buttonRegister: UIButton! {
        didSet {
            buttonRegister.roundCorners()
            buttonRegister.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var buttonFB: UIButton! {
        didSet {
            buttonFB.roundCorners()
            buttonFB.isHidden = true
        }
    }
    @IBOutlet weak var buttonGoogle: UIButton! {
        didSet {
            buttonGoogle.roundCorners()
            buttonGoogle.isHidden = true
        }
    }
    @IBOutlet weak var buttonAlreadyhaveAccount: UIButton! {
        didSet {
            buttonAlreadyhaveAccount.layer.borderWidth = 0.4
            buttonAlreadyhaveAccount.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBOutlet weak var containerViewSocialButton: UIView!
    
    //MARK:- Properties
    
    var isAgreeTerms = false
    var page_id = ""
    var defaults = UserDefaults.standard
    var isVerifivation = false
    var isVerifyOn = false
    
    
    //MARK:- Application Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        self.adForest_registerData()
        txtFieldsWithRtl()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
   
    
    //MARK:- Text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtName {
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail {
            txtPhone.becomeFirstResponder()
        }
        else if textField == txtPhone {
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword {
            txtPassword.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - Custom
    
    func txtFieldsWithRtl(){
        if UserDefaults.standard.bool(forKey: "isRtl") {
            txtEmail.textAlignment = .right
            txtPassword.textAlignment = .right
            txtName.textAlignment = .right
            txtPhone.textAlignment = .right
            
        } else {
            txtEmail.textAlignment = .left
            txtPassword.textAlignment = .left
            txtName.textAlignment = .left
            txtPhone.textAlignment = .left
        }
    }
    
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }

    func adForest_populateData() {
        if UserHandler.sharedInstance.objregisterDetails != nil {
            let objData = UserHandler.sharedInstance.objregisterDetails
            
            if let isVerification = objData?.isVerifyOn {
                self.isVerifyOn = isVerification
            }

            if let bgColor = defaults.string(forKey: "mainColor") {
                self.buttonRegister.layer.borderColor = Constants.hexStringToUIColor(hex: bgColor).cgColor
                self.buttonRegister.setTitleColor(Constants.hexStringToUIColor(hex: bgColor), for: .normal)
            }
            
            if let registerText = objData?.heading {
                self.lblregisterWithUs.text = registerText
            }
            if let nameText = objData?.namePlaceholder {
                self.txtName.placeholder = nameText
            }
            if let emailText = objData?.emailPlaceholder {
                self.txtEmail.placeholder = emailText
            }
            if let phoneText = objData?.phonePlaceholder {
                self.txtPhone.placeholder = phoneText
            }
            if let passwordtext = objData?.passwordPlaceholder {
                self.txtPassword.placeholder = passwordtext
            }
            if let termsText = objData?.termsText {
                self.buttonAgreeWithTermsConditions.setTitle(termsText, for: .normal)
            }
            if let registerText = objData?.formBtn {
                self.buttonRegister.setTitle(registerText, for: .normal)
            }

            if let loginText = objData?.loginText {
                self.buttonAlreadyhaveAccount.setTitle(loginText, for: .normal)
            }
            if let isUserVerification = objData?.isVerifyOn {
                self.isVerifivation = isUserVerification
            }
            
            // Show hide guest button
            guard let settings = defaults.object(forKey: "settings") else {
                return
            }
            let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settings as! Data) as! [String : Any]
            let objSettings = SettingsRoot(fromDictionary: settingObject)
            
            // Show/hide google and facebook button
            var isShowGoogle = false
            var isShowFacebook = false
            
            if let isGoogle = objSettings.data.registerBtnShow.google {
                isShowGoogle = isGoogle
            }
            if let isFacebook = objSettings.data.registerBtnShow.facebook{
                isShowFacebook = isFacebook
            }
            if isShowFacebook || isShowGoogle {
                if let sepratorText = objData?.separator {
                    self.lblOr.text = sepratorText
                }
            }
            
            if isShowFacebook && isShowGoogle {
                self.buttonFB.isHidden = false
                self.buttonGoogle.isHidden = false
                if let fbText = objData?.facebookBtn {
                    self.buttonFB.setTitle(fbText, for: .normal)
                }
                if let googletext = objData?.googleBtn {
                    self.buttonGoogle.setTitle(googletext, for: .normal)
                }
            }
                
            else if isShowFacebook && isShowGoogle == false {
                self.buttonFB.isHidden = false
                self.buttonFB.translatesAutoresizingMaskIntoConstraints = false
                buttonFB.leftAnchor.constraint(equalTo: self.containerViewSocialButton.leftAnchor, constant: 0).isActive = true
                buttonFB.rightAnchor.constraint(equalTo: self.containerViewSocialButton.rightAnchor, constant: 0).isActive = true
                if let fbText = objData?.facebookBtn {
                    self.buttonFB.setTitle(fbText, for: .normal)
                }
            }
                
            else if isShowGoogle && isShowFacebook == false {
                self.buttonGoogle.isHidden = false
                self.buttonGoogle.translatesAutoresizingMaskIntoConstraints = false
                buttonGoogle.leftAnchor.constraint(equalTo: self.containerViewSocialButton.leftAnchor, constant: 0).isActive = true
                buttonGoogle.rightAnchor.constraint(equalTo: self.containerViewSocialButton.rightAnchor, constant: 0).isActive = true
                
                if let googletext = objData?.googleBtn {
                    self.buttonGoogle.setTitle(googletext, for: .normal)
                }
            }
        }
    }
    
    //MARK: -IBActions
    
    @IBAction func checkBox(_ sender: UIButton) {
        
        if isAgreeTerms == false {
            buttonCheckBox.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
            isAgreeTerms = true
        }
        else if isAgreeTerms {
            buttonCheckBox.setBackgroundImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isAgreeTerms = false
        }
    }
    
    @IBAction func actionTermsCondition(_ sender: UIButton) {
        if self.page_id == "" {
        }
        else {
            let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsConditionsController") as! TermsConditionsController
            termsVC.modalTransitionStyle = .flipHorizontal
            termsVC.modalPresentationStyle = .overCurrentContext
            termsVC.page_id = self.page_id
            self.presentVC(termsVC)
        }
    }
    
    @IBAction func actionRegister(_ sender: UIButton) {
        
        guard let name = txtName.text else {
            return
        }
        guard let email = txtEmail.text else {
            return
        }
        guard let phone = txtPhone.text else {
            return
        }
        
        guard let password = txtPassword.text else {
            return
        }
        
        if name == "" {
             self.txtName.shake(6, withDelta: 10, speed: 0.06)
        }
        else if email == "" {
            self.txtEmail.shake(6, withDelta: 10, speed: 0.06)
        }
        else if !email.isValidEmail {
            self.txtEmail.shake(6, withDelta: 10, speed: 0.06)
        }
        
        else if phone == "" {
             self.txtPhone.shake(6, withDelta: 10, speed: 0.06)
        }
        else if !phone.isValidPhone {
             self.txtPhone.shake(6, withDelta: 10, speed: 0.06)
        }
        else if password == "" {
            self.txtPassword.shake(6, withDelta: 10, speed: 0.06)
        }

        else if isAgreeTerms == false {
            let alert = Constants.showBasicAlert(message: "Please Agree with terms and conditions")
            self.presentVC(alert)
        }
        else {
            let parameters : [String: Any] = [
                "name": name,
                "email": email,
                "phone": phone,
                "password": password
            ]
            print(parameters)
            defaults.set(email, forKey: "email")
            defaults.set(password, forKey: "password")
            self.adForest_registerUser(param: parameters as NSDictionary)
        }
    }
    
    @IBAction func actionFacebook(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Nothing")
            }
            else if (result?.isCancelled)! {
                print("Cancel")
            }
            else if error == nil {
                self.userProfileDetails()
            } else {
            }
        }
    }
    
    @IBAction func actionGoogle(_ sender: Any) {
        if GoogleAuthenctication.isLooggedIn {
            GoogleAuthenctication.signOut()
        }
        else {
            GoogleAuthenctication.signIn()
        }
    }
    
    @IBAction func actionLoginHere(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Facebook Delegate Methods
    
    func userProfileDetails() {
        if (FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, email, gender, picture.type(large)"]).start { (connection, result, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Nothing")
                    return
                }
                else {
                    guard let results = result as? NSDictionary else { return }
                     guard  let email = results["email"] as? String else {
                        return
                    }
                    let param: [String: Any] = [
                        "email": email,
                        "type": "social"
                    ]
                    print(param)
                    self.defaults.set(true, forKey: "isSocial")
                    self.defaults.set(email, forKey: "email")
                    self.defaults.set("1122", forKey: "password")
                    self.defaults.synchronize()
                    self.adForest_loginUser(parameters: param as NSDictionary)
                }
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    //MARK:- Google Delegate Methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        }
        if error == nil {
            guard let email = user.profile.email else { return }
            let param: [String: Any] = [
                "email": email,
                "type": "social"
            ]
            print(param)
            self.defaults.set(true, forKey: "isSocial")
            self.defaults.set(email, forKey: "email")
            self.defaults.set("1122", forKey: "password")
            self.defaults.synchronize()
            self.adForest_loginUser(parameters: param as NSDictionary)
        }
    }
    // Google Sign In Delegate
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- API Calls
    //Get Details Data
    func adForest_registerData() {
        self.showLoader()
        UserHandler.registerDetails(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                UserHandler.sharedInstance.objregisterDetails = successResponse.data
                if let pageID = successResponse.data.termPageId {
                    self.page_id = pageID
                }
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
    
    //MARK:- User Register
    func adForest_registerUser(param: NSDictionary) {
        self.showLoader()
        UserHandler.registerUser(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                if self.isVerifivation {
                    let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                        let confirmationVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                        confirmationVC.isFromVerification = true
                        confirmationVC.user_id = successResponse.data.id
                        self.navigationController?.pushViewController(confirmationVC, animated: true)
                    })
                   self.presentVC(alert)
                }
                else {
                    self.defaults.set(true, forKey: "isLogin")
                    self.defaults.synchronize()
                    self.appDelegate.moveToHome()
                }
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
    
    // Login User With Social
    func adForest_loginUser(parameters: NSDictionary) {
        self.showLoader()
        UserHandler.loginUser(parameter: parameters , success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success{
                if self.isVerifyOn && successResponse.data.isAccountConfirm == false {
                    let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                        let confirmationVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                        confirmationVC.isFromVerification = true
                        confirmationVC.user_id = successResponse.data.id
                        self.navigationController?.pushViewController(confirmationVC, animated: true)
                    })
                    self.presentVC(alert)
                }
                else {
                    self.defaults.set(true, forKey: "isLogin")
                    self.defaults.synchronize()
                    self.appDelegate.moveToHome()
                }
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

