//
//  ProfileController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView

class ProfileController: UIViewController , UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, SwiftyAdDelegate {
    
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
            tableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
            tableView.register(UINib(nibName: "AddsStatusCell", bundle: nil), forCellReuseIdentifier: "AddsStatusCell")
        }
    }
    
    //MARK:- Properties
    var dataArray = [ProfileDetailsData]()
    let defaults = UserDefaults.standard
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftyAd.shared.delegate = self 
        self.googleAnalytics(controllerName: "Profile Controller")
        self.adMob()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateUserProfile), object: nil, queue: nil) { (notification) in
            self.adForest_profileDetails()
        }
        if defaults.bool(forKey: "isLogin") == false {
            self.oltAdPost.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addLeftBarButtonWithImage(UIImage(named: "menu")!)
        self.adForest_profileDetails()
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func verifyNumberVC() {
        let verifyVC = self.storyboard?.instantiateViewController(withIdentifier: "VerifyNumberController") as! VerifyNumberController
        verifyVC.modalPresentationStyle = .overCurrentContext
        verifyVC.modalTransitionStyle = .crossDissolve
        verifyVC.dataToShow = UserHandler.sharedInstance.objProfileDetails
        self.presentVC(verifyVC)
    }
    
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
                        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 45).isActive = true
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
    
    //MARK:- AdMob Delegates
    func swiftyAdDidOpen(_ swiftyAd: SwiftyAd) {
        
    }
    
    func swiftyAdDidClose(_ swiftyAd: SwiftyAd) {
        
    }
    
    func swiftyAd(_ swiftyAd: SwiftyAd, didRewardUserWithAmount rewardAmount: Int) {
        
    }
    
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataArray.isEmpty {
            return 0
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let objData = dataArray[indexPath.row]
        
        if section == 0 {
            let cell: ProfileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            
            if let imgUrl = URL(string: objData.profileExtra.profileImg) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
            
            if let userName = objData.profileExtra.displayName {
                cell.lblName.text = userName
            }
            if let lastLogin = objData.profileExtra.lastLogin {
                cell.lblLastlogin.text = lastLogin
            }
            if let avgRating = objData.profileExtra.rateBar.text {
                cell.lblAvgRating.text = avgRating
            }
            if let isUserVerified = objData.profileExtra.verifyButon.text {
                cell.lblStatus.text = isUserVerified
                cell.lblStatus.backgroundColor = Constants.hexStringToUIColor(hex: objData.profileExtra.verifyButon.color)
            }
            if let ratingBar = objData.profileExtra.rateBar.number {
                cell.ratingBar.settings.updateOnTouch = false
                cell.ratingBar.settings.fillMode = .precise
                cell.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: "#ffcc00")
                cell.ratingBar.rating = Double(ratingBar)!
            }

            if let editButtonTitle = objData.profileExtra.editText {
                cell.buttonEditProfile.setTitle(editButtonTitle, for: .normal)
            }
            cell.actionEdit = { () in
                let editProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController") as! EditProfileController
                self.navigationController?.pushViewController(editProfileVC, animated: true)
            }
            
            return cell
        }
        else if section == 1 {
            let cell: AddsStatusCell = tableView.dequeueReusableCell(withIdentifier: "AddsStatusCell", for: indexPath) as! AddsStatusCell
            
            if let soldAds = objData.profileExtra.adsSold {
                cell.lblSoldAds.text = soldAds
            }
            if let allAds = objData.profileExtra.adsTotal {
                cell.lblAllAds.text = allAds
            }
            if let inactiveAds = objData.profileExtra.adsInactive {
                cell.lblInactiveAds.text = inactiveAds
            }
            return cell
        }
        else if section == 2 {
            let cell: UserProfileInformationCell = tableView.dequeueReusableCell(withIdentifier: "UserProfileInformationCell", for: indexPath) as! UserProfileInformationCell
            let detailsData = UserHandler.sharedInstance.objProfileDetails
            
            if let titleText = objData.pageTitle {
                cell.lblMyProfile.text = titleText
            }
            
            if let nameText = objData.displayName.key {
                cell.lblName.text = nameText
            }
            if let nameValue = objData.displayName.value {
                cell.lblNameValue.text = nameValue
            }
            if let emailText = objData.userEmail.key {
                cell.lblEmail.text = emailText
            }
            if let emailvalue = objData.userEmail.value {
                cell.lblEmailValue.text = emailvalue
            }
            
            if let phoneNumberText = objData.phone.key {
                cell.lblPhone.text = phoneNumberText
            }
            if let phoneNumberValue = objData.phone.value {
                cell.lblPhoneValue.text = phoneNumberValue
            }
            if let buttonVerificationTitle = detailsData?.extraText.isNumberVerifiedText {
                var attributedString = NSMutableAttributedString(string: "")
                let buttonTitle = NSMutableAttributedString(string: buttonVerificationTitle, attributes: cell.attributes)
                attributedString.append(buttonTitle)
                cell.buttonPhoneVerification.setAttributedTitle(attributedString, for: .normal)
            }
            
            var isVerificationOn = false
            if let isVerification = detailsData?.extraText.isVerificationOn {
                isVerificationOn = isVerification
            }
            
            if isVerificationOn {
                if (detailsData?.extraText.isNumberVerified)! {
                    cell.buttonPhoneVerification.backgroundColor = Constants.hexStringToUIColor(hex: Constants.AppColor.phoneVerified)
                }
                else {
                    cell.buttonPhoneVerification.backgroundColor = Constants.hexStringToUIColor(hex: Constants.AppColor.phoneNotVerified)
                    cell.clickNumberVerified = { () in
                        let alert = UIAlertController(title: detailsData?.extraText.sendSmsDialog.title, message: detailsData?.extraText.sendSmsDialog.text, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: detailsData?.extraText.sendSmsDialog.btnSend, style: .default, handler: { (okAcion) in
                            self.adForest_phoneNumberVerify()
                        })
                        let cancelAction = UIAlertAction(title: detailsData?.extraText.sendSmsDialog.btnCancel, style: .default, handler: nil)
                        alert.addAction(cancelAction)
                        alert.addAction(okAction)
                        self.presentVC(alert)
                    }
                }
            }
            else {
                cell.buttonPhoneVerification.isHidden = true
            }
            
            if let accountTypeText = objData.accountType.key {
                cell.lblAccountType.text = accountTypeText
            }
            
            if let accountTypeValue = objData.accountType.value {
                cell.lblAccountTypeValue.text = accountTypeValue
            }
            if let locationText = objData.location.key {
                cell.lblLocation.text = locationText
            }
            if let locationValue = objData.location.value {
                cell.lblLocationValue.text = locationValue
            }
            if let packageTypetext = objData.packageType.key {
                cell.lblPackageType.text = packageTypetext
            }
            if let packageValue = objData.packageType.value {
                cell.lblPackageTypeValue.text = packageValue
            }
            if let simpleAddtext = objData.simpleAds.key {
                cell.lblSimpleAds.text = simpleAddtext
            }
            if let simpleAddValue = objData.simpleAds.value {
                cell.lblSimpleAdsvalue.text = simpleAddValue
            }
            
            if let featureAddText = objData.featuredAds.key {
                cell.lblFeatureAds.text = featureAddText
            }
            if let featureAddValue = objData.featuredAds.value {
                cell.lblFeatureAdsValue.text = featureAddValue
            }
            if let bumpAddText = objData.bumpAds.key {
                cell.lblBumpAds.text = bumpAddText
            }
            if let bumpAddValue = objData.bumpAds.value {
                cell.lblBumpAdsValue.text = bumpAddValue
            }
            if let expireDateText = objData.expireDate.key {
                cell.lblExpiryDate.text = expireDateText
            }
            if let expireValue = objData.expireDate.value {
                cell.lblExpiryDateValue.text = expireValue
            }
            var isShowBlockUser = false
            if let isShowUser = objData.blockedUsersShow {
                isShowBlockUser = isShowUser
            }
            
            if isShowBlockUser {
                cell.oltBlockedUsers.isHidden = false
                if let btnText = objData.blockedUsers.value {
                    cell.oltBlockedUsers.setTitle(btnText, for: .normal)
                }
                if let lblText = objData.blockedUsers.key {
                    cell.lblBlockedUser.text = lblText
                }
                cell.btnBlockUser = { () in
                    let blockedVC = self.storyboard?.instantiateViewController(withIdentifier: "BlockedUserController") as! BlockedUserController
                    self.navigationController?.pushViewController(blockedVC, animated: true)
                }
            } else {
                cell.oltBlockedUsers.isHidden = true
                cell.lblBlockedUser.isHidden = true
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 {
            let userRatingVC = self.storyboard?.instantiateViewController(withIdentifier: "UserRatingController") as! UserRatingController
            self.navigationController?.pushViewController(userRatingVC, animated: true)
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 110
        case 1:
            return 65
        case 2:
            return 550
        default:
            return 0
        }
    }
    
    //MARK:- IBActions
    @IBAction func actionAdpost(_ sender: UIButton) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    
    
    //MARK:- API Call
    
    // Profile Details
    func adForest_profileDetails() {
        self.showLoader()
        UserHandler.profileGet(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.dataArray = [successResponse.data]
                self.title = successResponse.extraText.profileTitle
                UserHandler.sharedInstance.objProfileDetails = successResponse
                self.tableView.reloadData()
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
    
    //Verify Phone Number
    func adForest_phoneNumberVerify() {
        self.showLoader()
        UserHandler.verifyPhone(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.verifyNumberVC()
                })
                self.presentVC(alert)
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

class UserProfileInformationCell: UITableViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblMyProfile: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNameValue: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblEmailValue: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblPhoneValue: UILabel!
    @IBOutlet weak var buttonPhoneVerification: UIButton!
    @IBOutlet weak var lblAccountType: UILabel!
    @IBOutlet weak var lblAccountTypeValue: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLocationValue: UILabel!
    @IBOutlet weak var lblPackageType: UILabel!
    @IBOutlet weak var lblPackageTypeValue: UILabel!
    @IBOutlet weak var lblSimpleAds: UILabel!
    @IBOutlet weak var lblSimpleAdsvalue: UILabel!
    @IBOutlet weak var lblFeatureAds: UILabel!
    @IBOutlet weak var lblFeatureAdsValue: UILabel!
    @IBOutlet weak var lblBumpAds: UILabel!
    @IBOutlet weak var lblBumpAdsValue: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var lblExpiryDateValue: UILabel!
    @IBOutlet weak var lblBlockedUser: UILabel!
    
    @IBOutlet weak var oltBlockedUsers: UIButton!
    //MARK:- Properties
    
    var clickNumberVerified: (()->())?
    var btnBlockUser: (()->())?
    
    var attributes : [NSAttributedStringKey : Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : 1]
    
    //MARK:- view Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction func actionPhoneVerified(_ sender: UIButton) {
        clickNumberVerified?()
    }
    
    @IBAction func actionBlockedUser(_ sender: UIButton) {
        self.btnBlockUser?()
    }
}



