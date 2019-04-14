//
//  LoginViewController.swift
//  Adforest
//
//  Created by apple on 1/2/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import NVActivityIndicatorView
import SDWebImage
import UITextField_Shake

class LoginViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable, GIDSignInUIDelegate, GIDSignInDelegate, UIScrollViewDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.isScrollEnabled = false
        }
    }
    @IBOutlet weak var containerViewImage: UIView!
    @IBOutlet weak var imgTitle: UIImageView!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var imgEmail: UIImageView!
    @IBOutlet weak var txtEmail: UITextField! {
        didSet {
            txtEmail.delegate = self
        }
    }
    @IBOutlet weak var imgPassword: UIImageView!
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            txtPassword.delegate = self
        }
    }
    @IBOutlet weak var buttonForgotPassword: UIButton!{
        didSet{
            buttonForgotPassword.contentHorizontalAlignment = .right
        }
    }
    @IBOutlet weak var buttonSubmit: UIButton! {
        didSet {
            buttonSubmit.roundCorners()
            buttonSubmit.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var buttonFBLogin: UIButton! {
        didSet {
            buttonFBLogin.roundCorners()
            buttonFBLogin.isHidden = true
        }
    }
    @IBOutlet weak var buttonGoogleLogin: UIButton! {
        didSet {
            buttonGoogleLogin.roundCorners()
            buttonGoogleLogin.isHidden = true
        }
    }
    
    @IBOutlet weak var buttonGuestLogin: UIButton! {
        didSet {
            buttonGuestLogin.roundCorners()
            buttonGuestLogin.layer.borderWidth = 1
            buttonGuestLogin.isHidden = true
        }
    }
    
    @IBOutlet weak var buttonRegisterWithUs: UIButton! {
        didSet {
            buttonRegisterWithUs.layer.borderWidth = 0.4
            buttonRegisterWithUs.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    @IBOutlet weak var viewRegisterWithUs: UIView!
    @IBOutlet weak var containerViewSocialButton: UIView!
    
    
    //MARK:- Properties
    var getLoginDetails = [LoginData]()
    var defaults = UserDefaults.standard
    var isVerifyOn = false
    
    // MARK: Application Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        self.adForest_loginDetails()
        txtFieldsWithRtl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        defaults.removeObject(forKey: "isGuest")
        defaults.synchronize()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
   
    //MARK:- text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword {
            txtPassword.resignFirstResponder()
            self.adForest_logIn()
        }
        return true
    }
    
    //MARK: - Custom
    
    func txtFieldsWithRtl(){
        if UserDefaults.standard.bool(forKey: "isRtl") {
            txtEmail.textAlignment = .right
            txtPassword.textAlignment = .right
        } else {
            txtEmail.textAlignment = .left
            txtPassword.textAlignment = .left
        }
    }
    
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if UserHandler.sharedInstance.objLoginDetails != nil {
            let objData = UserHandler.sharedInstance.objLoginDetails
           
            if let isVerification = objData?.isVerifyOn {
                self.isVerifyOn = isVerification
            }
            
            if let bgColor = defaults.string(forKey: "mainColor") {
                self.containerViewImage.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
                self.buttonSubmit.layer.borderColor = Constants.hexStringToUIColor(hex: bgColor).cgColor
                self.buttonGuestLogin.layer.borderColor = Constants.hexStringToUIColor(hex: bgColor).cgColor
                self.buttonSubmit.setTitleColor(Constants.hexStringToUIColor(hex: bgColor), for: .normal)
                self.buttonGuestLogin.setTitleColor(Constants.hexStringToUIColor(hex: bgColor), for: .normal)
            }
            
            if let imgUrl = URL(string: (objData?.logo)!) {
                imgTitle.sd_setShowActivityIndicatorView(true)
                imgTitle.sd_setIndicatorStyle(.gray)
                imgTitle.sd_setImage(with: imgUrl, completed: nil)
            }
            
            if let welcomeText = objData?.heading {
                self.lblWelcome.text = welcomeText
            }
            if let emailPlaceHolder = objData?.emailPlaceholder {
                self.txtEmail.placeholder = emailPlaceHolder
            }
            if let passwordPlaceHolder = objData?.passwordPlaceholder {
                self.txtPassword.placeholder = passwordPlaceHolder
            }
            if let forgotText = objData?.forgotText {
                self.buttonForgotPassword.setTitle(forgotText, for: .normal)
            }
            if let submitText = objData?.formBtn {
                self.buttonSubmit.setTitle(submitText, for: .normal)
            }
           
            if let registerText = objData?.registerText {
                self.buttonRegisterWithUs.setTitle(registerText, for: .normal)
            }
            
            // Show hide guest button
            guard let settings = defaults.object(forKey: "settings") else {
                return
            }
            let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settings as! Data) as! [String : Any]
            let objSettings = SettingsRoot(fromDictionary: settingObject)

            
            var isShowGuestButton = false
            if let isShowGuest = objSettings.data.isAppOpen {
                isShowGuestButton = isShowGuest
            }
            if isShowGuestButton {
                self.buttonGuestLogin.isHidden = false
                if let guestText = objData?.guestLogin {
                    self.buttonGuestLogin.setTitle(guestText, for: .normal)
                }
            }
            else {
                  self.buttonGuestLogin.isHidden = true
            }

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
                self.buttonFBLogin.isHidden = false
                self.buttonGoogleLogin.isHidden = false
                if let fbText = objData?.facebookBtn {
                    self.buttonFBLogin.setTitle(fbText, for: .normal)
                }
                if let googletext = objData?.googleBtn {
                    self.buttonGoogleLogin.setTitle(googletext, for: .normal)
                }
            }
        
          else if isShowFacebook && isShowGoogle == false {
                self.buttonFBLogin.isHidden = false
                self.buttonFBLogin.translatesAutoresizingMaskIntoConstraints = false
                buttonFBLogin.leftAnchor.constraint(equalTo: self.containerViewSocialButton.leftAnchor, constant: 0).isActive = true
                buttonFBLogin.rightAnchor.constraint(equalTo: self.containerViewSocialButton.rightAnchor, constant: 0).isActive = true
                if let fbText = objData?.facebookBtn {
                    self.buttonFBLogin.setTitle(fbText, for: .normal)
                }
            }
                
           else if isShowGoogle && isShowFacebook == false {
                self.buttonGoogleLogin.isHidden = false
                self.buttonGoogleLogin.translatesAutoresizingMaskIntoConstraints = false
                buttonGoogleLogin.leftAnchor.constraint(equalTo: self.containerViewSocialButton.leftAnchor, constant: 0).isActive = true
                buttonGoogleLogin.rightAnchor.constraint(equalTo: self.containerViewSocialButton.rightAnchor, constant: 0).isActive = true
               
                if let googletext = objData?.googleBtn {
                    self.buttonGoogleLogin.setTitle(googletext, for: .normal)
                }    
            }
            else if isShowFacebook == false && isShowGoogle == false {
                self.containerViewSocialButton.isHidden = true
                if isShowGuestButton {
                    self.buttonGuestLogin.isHidden = false
                    self.buttonGuestLogin.translatesAutoresizingMaskIntoConstraints = false
                    buttonGuestLogin.topAnchor.constraint(equalTo: self.buttonSubmit.bottomAnchor, constant: 8).isActive = true
                    if let guestText = objData?.guestLogin {
                        self.buttonGuestLogin.setTitle(guestText, for: .normal)
                    }
                } else {
                    self.buttonGuestLogin.isHidden = true
                }
            }
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func actionForgotPassword(_ sender: Any) {
        let forgotPassVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
    }
    
    @IBAction func actionSubmit(_ sender: Any) {
        self.adForest_logIn()
    }
    
    func adForest_logIn() {
        guard let email = txtEmail.text else {
            return
        }
        guard let password = txtPassword.text else {
            return
        }
        if email == "" {
            self.txtEmail.shake(6, withDelta: 10, speed: 0.06)
        }
        else if !email.isValidEmail {
            self.txtEmail.shake(6, withDelta: 10, speed: 0.06)
        }
        else if password == "" {
             self.txtPassword.shake(6, withDelta: 10, speed: 0.06)
        }
        else {
            let param : [String : Any] = [
                                            "email" : email,
                                            "password": password
                                        ]
            print(param)
            self.defaults.set(email, forKey: "email")
            self.defaults.set(password, forKey: "password")
            self.adForest_loginUser(parameters: param as NSDictionary)
        }
    }
    
    @IBAction func actionFBLogin(_ sender: Any) {
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
    
    @IBAction func actionGoogleLogin(_ sender: Any) {
        if GoogleAuthenctication.isLooggedIn {
            GoogleAuthenctication.signOut()
        }
        else {
            GoogleAuthenctication.signIn()
        }
    }
    
    @IBAction func actionGuestLogin(_ sender: Any) {
        defaults.set(true, forKey: "isGuest")
        self.showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.appDelegate.moveToHome()
            self.stopAnimating()
        }
    }
    
    @IBAction func actionRegisterWithUs(_ sender: Any) {
        let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(registerVC, animated: true)
    }

    //MARK:- Google Delegate Methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        }
        if error == nil {
            guard let email = user.profile.email,
                let googleID = user.userID,
                let name = user.profile.name
                else { return }
            guard let token = user.authentication.idToken else {
                return
            }
            print("\(email), \(googleID), \(name), \(token)")
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
                    guard let facebookId = results["email"] as? String,
                        let email = results["email"] as? String else {
                            return
                    }
                    print("\(email), \(facebookId)")
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
    
    
    //MARK:- API Calls
    
    //Login Data Get Request
    func adForest_loginDetails() {
        self.showLoader()
        UserHandler.loginDetails(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                UserHandler.sharedInstance.objLoginDetails = successResponse.data
                self.adForest_populateData()
            } else {
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
                if self.isVerifyOn && successResponse.data.isAccountConfirm == false {
                    let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                        let confirmationVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
                        confirmationVC.isFromVerification = true
                        confirmationVC.user_id = successResponse.data.id
                        self.navigationController?.pushViewController(confirmationVC, animated: true)
                    })
                    self.presentVC(alert)
                } else {
                    self.defaults.set(true, forKey: "isLogin")
                    self.defaults.synchronize()
                    self.appDelegate.moveToHome()
                }
            } else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
}
