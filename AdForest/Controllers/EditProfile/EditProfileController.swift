//
//  EditProfileController.swift
//  AdForest
//
//  Created by apple on 3/12/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import TextFieldEffects
import DropDown
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import NVActivityIndicatorView

class EditProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            let nib = UINib(nibName: "ProfileCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "ProfileCell")
            let nibStatus = UINib(nibName: "AddsStatusCell", bundle: nil)
            tableView.register(nibStatus, forCellReuseIdentifier: "AddsStatusCell")
        }
    }
    
    @IBOutlet weak var oltAdPost: UIButton! {
        didSet {
            oltAdPost.circularButton()
            if let bgColor = UserDefaults.standard.string(forKey: "mainColor") {
                oltAdPost.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    
    //MARK:- Properties
    
    var userAddress = ""
    var accountTypeArray = [String]()
    var dataArray = [ProfileDetailsData]()
    let defaults = UserDefaults.standard
    
    //MARK:- View Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UserHandler.sharedInstance.objProfileDetails?.extraText.profileEditTitle
        self.showBackButton()
        self.googleAnalytics(controllerName: "Edit Profile Controller")
        self.hideKeyboard()
        self.adForest_profileDetails()
        self.adMob()
        if defaults.bool(forKey: "isGuest") {
            self.oltAdPost.isHidden = true
        }
    }
    
    //MARK:- Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
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
                        SwiftyAd.shared.showBanner(from: self, at: .top)
                        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 45).isActive = true
                    }
                    else {
                        SwiftyAd.shared.showBanner(from: self, at: .bottom)
                        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 50).isActive = true
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
         let objData = dataArray[indexPath.row]
        if section == 0 {
            let cell: ProfileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            
           // let objData = dataArray[indexPath.row]
            cell.containerViewEditProfile.isHidden = true
            
            if let imgUrl = URL(string: objData.profileExtra.profileImg) {
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
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
            return cell
        }
            
        else if section == 1 {
            let cell: AddsStatusCell = tableView.dequeueReusableCell(withIdentifier: "AddsStatusCell", for: indexPath) as! AddsStatusCell
           // let objData = dataArray[indexPath.row]
            
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
            
            let cell : EditProfileCell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell", for: indexPath) as! EditProfileCell
           
            let extraData = UserHandler.sharedInstance.objProfileDetails
            
            if row == 0 {
                if let title = extraData?.extraText.profileEditTitle {
                    cell.lblEditProfile.text = title
                }
                if let changePasswordTitle = extraData?.extraText.changePass.title {
                    cell.buttonChangePassword.setTitle(changePasswordTitle, for: .normal)
                }
                cell.btnChangePassword = { () in
                    let passVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordController") as! ChangePasswordController
                    passVC.modalPresentationStyle = .overCurrentContext
                    passVC.modalTransitionStyle = .crossDissolve
                    passVC.dataToShow = extraData
                    self.presentVC(passVC)
                }
                
                if let nameText = objData.displayName.key {
                    cell.lblName.text = nameText
                }
                
                if let nameValue = objData.displayName.value {
                    cell.txtName.text = nameValue
                }
                if let phoneText = objData.phone.key {
                    cell.lblPhone.text = phoneText
                }
                if let phoneValue = objData.phone.value {
                    cell.txtPhone.text = phoneValue
                }
                if let accountTypeText = objData.accountType.key {
                    cell.lblAccountType.text = accountTypeText
                }
                if let dropDownButtontext = objData.accountType.value {
                    cell.buttonAccountType.setTitle(dropDownButtontext, for: .normal)
                    cell.accountType = dropDownButtontext
                }
                
                cell.btnDropDown = { () in
                    cell.dropDownDataArray = []
                    for items in objData.accountTypeSelect {
                        cell.dropDownDataArray.append(items.value)
                    }
                    cell.accountDropDown()
                    cell.accountTypeDropDown.show()
                }
                
                if let locationText = objData.location.key {
                    cell.lblAddress.text = locationText
                }
                if let locationValue = objData.location.value {
                    cell.textAddress.text = locationValue
                    
                }
                
                if let imgText = objData.profileImg.key {
                    cell.lblImage.text = imgText
                }
                if let imgUrl = URL(string: objData.profileImg.value) {
                    cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                    cell.imgPicture.sd_setIndicatorStyle(.gray)
                    cell.imgPicture.sd_setShowActivityIndicatorView(true)
                }
                if let introductionText = objData.introduction.key {
                    cell.lblIntroduction.text = introductionText
                }
                if let introductionValue = objData.introduction.value {
                    cell.txtIntroduction.text = introductionValue
                }
                if let updateTitle = extraData?.extraText.saveBtn {
                    cell.buttonUpdate.setTitle(updateTitle, for: .normal)
                }
                
                if let title = extraData?.extraText.selectPic.title {
                    cell.titleAddPhotos = title
                }
                if let cameratext = extraData?.extraText.selectPic.camera {
                    cell.titleCamera = cameratext
                }
                if let galleryText = extraData?.extraText.selectPic.library {
                    cell.titleGallery = galleryText
                }
                if let cancelText = extraData?.extraText.selectPic.cancel {
                    cell.titleCancel = cancelText
                }
                if let cameraNotText = extraData?.extraText.selectPic.noCamera {
                    cell.titleCameraNotAvailable = cameraNotText
                }
                
                var canDeleteAccount = false
                
                if let canDelete = extraData?.data.canDeleteAccount {
                    canDeleteAccount = canDelete
                }
                
                if canDeleteAccount {
                    cell.buttonDelete.isHidden = false
                    if let deleteButtonText = extraData?.data.deleteAccount.text {
                        cell.buttonDelete.setTitle(deleteButtonText, for: .normal)
                    }
                    cell.btnDelete = { () in
                        var message = ""
                        var btnCancel = ""
                        var btnConfirm = ""
                        if let popUpText = extraData?.data.deleteAccount.popuptext {
                            message = popUpText
                        }
                        if let confirmText = extraData?.data.deleteAccount.btnSubmit {
                            btnConfirm = confirmText
                        }
                        if let cancelText = extraData?.data.deleteAccount.btnCancel {
                            btnCancel = cancelText
                        }
                        var id = 0
                        if let userID = extraData?.data.id {
                            id = userID
                        }
                        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: btnConfirm, style: .default) { (action) in
                            let param: [String: Any] = ["user_id": id]
                            print(param)
                            self.adForest_deleteAccount(param: param as NSDictionary)
                        }
                        let cancelAction = UIAlertAction(title: btnCancel, style: .default, handler: nil)
                        alert.addAction(cancelAction)
                        alert.addAction(confirmAction)
                        self.presentVC(alert)
                    }
                }
                else {
                    cell.buttonDelete.isHidden = true
                }
            }
                return cell
            }
                return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        var height: CGFloat = 0
        if section == 0 {
            height = 110
        }
        else if section == 1 {
            height = 65
        }
        else if section == 2 {
            height = 810
        }
       
        return height
    }
    
    //MARK:- IBActions
    @IBAction func actionAdPost(_ sender: UIButton) {
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
                UserHandler.sharedInstance.objProfileDetails = successResponse
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
    
    //Delete Account
    func adForest_deleteAccount(param: NSDictionary) {
        self.showLoader()
        UserHandler.deleteAccount(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.defaults.set(false, forKey: "isLogin")
                    self.defaults.set(false, forKey: "isGuest")
                    self.defaults.set(false, forKey: "isSocial")
                    self.appDelegate.moveToLogin()
                })
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
}


class EditProfileCell: UITableViewCell, UITextFieldDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {

    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblEditProfile: UILabel!
    @IBOutlet weak var buttonChangePassword: UIButton!{
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                buttonChangePassword.setTitleColor(Constants.hexStringToUIColor(hex: mainColor), for: .normal)
            }
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var lblAccountType: UILabel!
    @IBOutlet weak var buttonAccountType: UIButton! {
        didSet {
            buttonAccountType.contentHorizontalAlignment = .left
        }
    }
    @IBOutlet weak var imgDropDown: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var textAddress: UITextView! {
        didSet {
            textAddress.delegate = self
            textAddress.layer.borderWidth = 0.5
            textAddress.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
  
    @IBOutlet weak var lblImage: UILabel!
    @IBOutlet weak var imgPicture: UIImageView! {
        didSet {
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(adForest_imageGet))
            imgPicture.addGestureRecognizer(tapImage)
            imgPicture.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var lblIntroduction: UILabel!
    @IBOutlet weak var txtIntroduction: UITextView! {
        didSet {
            txtIntroduction.layer.borderWidth = 0.5
            txtIntroduction.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var txtFacebook: HoshiTextField!
    @IBOutlet weak var txtTwitter: HoshiTextField!
    @IBOutlet weak var txtLinkedIn: HoshiTextField!
    @IBOutlet weak var txtGooglePlus: HoshiTextField!
    @IBOutlet weak var buttonUpdate: UIButton!
    @IBOutlet weak var buttonDelete: UIButton! {
        didSet {
            if let mainColor = defaults.string(forKey: "mainColor"){
                buttonDelete.setTitleColor(Constants.hexStringToUIColor(hex: mainColor), for: .normal)
            }
        }
    }
    
    //MARK:- Properties
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var imagePicker = UIImagePickerController()
    var defaults = UserDefaults.standard
   
    var imageUrl : URL!
    var imageSelect: UIImage!
    let fileName = "profile_img"
    
    var titleAddPhotos = ""
    var titleCamera = ""
    var titleGallery = ""
    var titleCancel = ""
    var titleCameraNotAvailable = ""
    
    var accountType = ""
    
    let accountTypeDropDown = DropDown()
    lazy var dropDowns : [DropDown] = {
        return [
            self.accountTypeDropDown
        ]
    }()
    
    var btnDropDown : (()->())?
    var btnChangePassword: (()->())?
    var btnUpdate: (()->())?
    var dropDownDataArray = [String]()
    var btnDelete: (()->())?
    
    //MARK:- View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    //MARK:- Custom
    
    @objc func adForest_imageGet() {
        let alert = UIAlertController(title: titleAddPhotos, message: nil, preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: titleCamera, style: .default) { (actionIn) in
            self.adForest_openCamera()
        }
        
        let galleryAction = UIAlertAction(title: titleGallery, style: .default) { (actionIn) in
            self.adForest_openGallery()
        }
        let cancelAction = UIAlertAction(title: titleCancel, style: .default) { (actionIn) in
            self.adForest_cancel()
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.appDel.presentController(ShowVC: alert)
    }
    
    func adForest_openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            self.appDel.presentController(ShowVC: imagePicker)
        }
        else {
            let alert = Constants.showBasicAlert(message: titleCameraNotAvailable)
            self.appDel.presentController(ShowVC: alert)
        }
    }
    
    func adForest_openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.appDel.presentController(ShowVC: imagePicker)
        }
        else {
            
        }
    }
    
    func adForest_cancel() {
        self.appDel.dissmissController()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgPicture.image = pickedImage
            imageSelect = pickedImage
            saveFileToDocumentDirectory(image: imageSelect)
            self.adForest_uploadImage()
        }
        self.appDel.dissmissController()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.appDel.dissmissController()
    }
    
    func saveFileToDocumentDirectory(image: UIImage) {
        if let savedUrl = FileManager.default.saveFileToDocumentsDirectory(image: image, name: self.fileName, extention: ".png") {
            self.imageUrl = savedUrl
            print("Library \(imageUrl)")
        }
    }
    
    func removeFileFromDocumentsDirectory(fileUrl: URL) {
        _ = FileManager.default.removeFileFromDocumentsDirectory(fileUrl: fileUrl)
    }
    
    //MARK:- Text View Delegate Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        let searchVC = GMSAutocompleteViewController()
        searchVC.delegate = self
        self.window?.rootViewController?.present(searchVC, animated: true, completion: nil)
    }
    
    
   // Google Places Delegate Methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place Name : \(place.name)")
        print("Place Address : \(place.formattedAddress ?? "null")")
        textAddress.text = place.formattedAddress
        self.appDel.dissmissController()
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.appDel.dissmissController()
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Cancelled")
        self.appDel.dissmissController()
    }

    //MARK:- SetUp Drop Down
    func accountDropDown() {
        accountTypeDropDown.anchorView = buttonAccountType
        accountTypeDropDown.dataSource = dropDownDataArray
        accountTypeDropDown.selectionAction = { [unowned self]
            (index, item) in
            self.buttonAccountType.setTitle(item, for: .normal)
            self.accountType = item
            print(self.accountType)
        }
    }
    
    @IBAction func actionChangePassword(_ sender: UIButton) {
        btnChangePassword?()
    }
   
    @IBAction func actionAccountType(_ sender: Any) {
        btnDropDown?()
    }
    
    @IBAction func actionUpdate(_ sender: Any) {
      //  btnUpdate?()
        
        guard let name = txtName.text else {
            return
        }
        guard let phone = txtPhone.text else {
            return
        }
        
        guard let location = textAddress.text else {
            return
        }
        guard let introduction = txtIntroduction.text else {
            return
        }
        
        let parameters: [String: Any] = [
            "user_name": name,
            "phone_number": phone,
            "account_type": accountType,
            "location": location,
            "user_introduction" : introduction,
            "social_icons": ""
        ]
        print(parameters)
        self.adForest_updateProfile(params: parameters as NSDictionary)
    }
    
    @IBAction func actionDelete(_ sender: Any) {
        self.btnDelete?()
    }
    
    
    //MARK:- API CALL
    func adForest_uploadImage() {
       let editprofile = EditProfileController()
        editprofile.showLoader()
        UserHandler.imageUpdate(fileUrl: imageUrl, fileName: fileName,uploadProgress: { (uploadProgress) in
            print(uploadProgress)
            
        }, success: { (sucessResponse) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if sucessResponse.success {
                let alert = AlertView.prepare(title: "", message: sucessResponse.message , okAction: {
                    self.removeFileFromDocumentsDirectory(fileUrl: self.imageUrl)
                    //post notification to update data in side menu
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.updateUserProfile), object: nil)
                   self.appDel.popController()
                })
                self.appDel.presentController(ShowVC: alert)
            }
            else {
                let alert = Constants.showBasicAlert(message: sucessResponse.message)
                self.appDel.presentController(ShowVC: alert)
            }
        }) { (error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.appDel.presentController(ShowVC: alert)
        }
    }
    
    func adForest_updateProfile(params: NSDictionary) {
        let editprofile = EditProfileController()
        editprofile.showLoader()
        UserHandler.profileUpdate(parameters: params, success: { (successResponse) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.appDel.presentController(ShowVC: alert)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.appDel.presentController(ShowVC: alert)
            }
        }) { (error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.appDel.presentController(ShowVC: alert)
        }
    }
}
