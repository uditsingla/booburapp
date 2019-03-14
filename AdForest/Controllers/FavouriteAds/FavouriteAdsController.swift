//
//  FavouriteAdsController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import Cosmos
import NVActivityIndicatorView

class FavouriteAdsController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {

    
    //MARK:- Outlets
    @IBOutlet weak var scrollBar: UIScrollView! {
        didSet {
            scrollBar.delegate = self
            scrollBar.isScrollEnabled = true
            scrollBar.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerViewProfile: UIView! {
        didSet {
            containerViewProfile.addShadowToView()
        }
    }
    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddType: UILabel!
    @IBOutlet weak var lblLastLogin: UILabel!
    @IBOutlet weak var buttonEditProfile: UIButton!
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var containerViewLblAdds: UIView!
    @IBOutlet weak var lblSoldAds: UILabel!
    @IBOutlet weak var lblAllAds: UILabel!
    @IBOutlet weak var lblInactiveAds: UILabel!

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsVerticalScrollIndicator = false
        }
    }
    
    @IBOutlet weak var lblNoData: UILabel! {
        didSet {
            lblNoData.isHidden = true
        }
    }
    
    @IBOutlet weak var oltAdPost: UIButton!{
        didSet {
            oltAdPost.circularButton()
            if let bgColor = defaults.string(forKey: "mainColor") {
                oltAdPost.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    
    //MARK:- Properties
    
    var dataArray = [MyAdsAd]()
    var data : MyAdsRoot?
    var noAddTitle = ""
    
    
    var defaults = UserDefaults.standard
    var settingObject = [String: Any]()
    
    var popUpMsg = ""
    var popUpText = ""
    var popUpCancelButton = ""
    var popUpOkButton = ""
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "isRtl") {
            self.addRightBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
        else {
            self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Favourite Ads Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        
        self.adForest_settingsData()
        self.adForest_favouriteAdsData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       // scrollBar.contentSize = CGSize(width: self.view.frame.size.width, height: 800)
    }
    
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if AddsHandler.sharedInstance.objMyAds != nil {
            let objData = AddsHandler.sharedInstance.objMyAds
            
            self.title = objData?.pageTitle
            
            if let imgUrl = URL(string: (objData?.profile.profileImg)!) {
                self.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                self.imgPicture.sd_setIndicatorStyle(.gray)
                self.imgPicture.sd_setShowActivityIndicatorView(true)
            }
            if let userName = objData?.profile.displayName {
                self.lblName.text = userName
            }
            if let isAddVerified = objData?.profile.verifyButon.text {
                self.lblAddType.text = isAddVerified
            }
            if let isAddVerifiedbackgroundColor = objData?.profile.verifyButon.color {
                self.lblAddType.backgroundColor = Constants.hexStringToUIColor(hex: isAddVerifiedbackgroundColor)
            }
            if let lastLoginTime = objData?.profile.lastLogin {
                self.lblLastLogin.text = lastLoginTime
            }
            if let editProfileText = objData?.profile.editText {
                self.buttonEditProfile.setTitle(editProfileText, for: .normal)
            }
            
            if let rateBar = objData?.profile.rateBar.number {
                self.ratingBar.settings.updateOnTouch = false
                self.ratingBar.settings.fillMode = .precise
                self.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: "#ffcc00")
                self.ratingBar.rating = Double(rateBar)!
            }
            if let avgRating = objData?.profile.rateBar.text {
                self.lblLikes.text = avgRating
            }
            
            if let soldAds = objData?.profile.adsSold {
                self.lblSoldAds.text = soldAds
            }
            if let allAds = objData?.profile.adsTotal {
                self.lblAllAds.text = allAds
            }
            if let inactiveAds = objData?.profile.adsInactive {
                self.lblInactiveAds.text = inactiveAds
            }
        }
        else {
        }
    }
    
    func adForest_settingsData() {
        if let settingsInfo = defaults.object(forKey: "settings") {
            settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
            print(settingObject)
        
            let model = SettingsRoot(fromDictionary: settingObject)
            print(model)
            
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
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if dataArray.count == 0 {
            self.collectionView.isHidden = true
            lblNoData.isHidden = false
            self.lblNoData.text = noAddTitle
        }
        collectionView.isHidden = false
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FavouriteCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCollectionCell", for: indexPath) as! FavouriteCollectionCell
        let objData = dataArray[indexPath.row]
        
        for images in objData.adImages {
            if let imgUrl = URL(string: images.thumb) {
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
            }
        }
        
        if let name = objData.adTitle {
            cell.lblName.text = name
        }
        if let price = objData.adPrice.price {
            cell.lblPrice.text = price
        }
        if let mainColor = defaults.string(forKey: "mainColor") {
            cell.lblPrice.textColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        
        if let addStatus = objData.adStatus.statusText {
            cell.lblAddType.text = addStatus
        }
        
        let statusType = objData.adStatus.status
        
        if statusType == "expired" {
            cell.lblAddType.backgroundColor = Constants.hexStringToUIColor(hex: "#d9534f")
        }
        else if statusType == "active" {
            cell.lblAddType.backgroundColor = Constants.hexStringToUIColor(hex: "#4caf50")
        }
        else if statusType == "sold" {
            cell.lblAddType.backgroundColor = Constants.hexStringToUIColor(hex: "#3498db")
        }
        
        cell.crossAction = { () in
            let alert = UIAlertController(title: self.popUpMsg, message: self.popUpText, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: self.popUpOkButton, style: .default, handler: { (okAction) in
                
                let parameter : [String: Any] = ["ad_id": objData.adId]
                print(parameter)
                self.adForest_removeFavourite(param: parameter as NSDictionary)
            })
            
            let cancelAction = UIAlertAction(title: self.popUpCancelButton, style: .default, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.presentVC(alert)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if Constants.isiPhone5 {
            return CGSize(width: 139 * (self.view.frame.size.width/295), height: 230 * (self.view.frame.size.height/568))
        }
        else if Constants.isIphoneX {
            return CGSize(width: 139 * (self.view.frame.size.width/295), height: 160 * (self.view.frame.size.height/568))
        }
        else if Constants.isIphone6 {
            return CGSize(width: 139 * (self.view.frame.size.width/295), height: 190 * (self.view.frame.size.height/568))
        }
        else if Constants.isiPadDevice {
            return CGSize(width: 139 * (self.view.frame.size.width/295), height: 200)
        }
        return CGSize(width: 139 * (self.view.frame.size.width/295), height: 190 * (self.view.frame.size.height/568))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let addDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        addDetailVC.isFromFavAds = true
        addDetailVC.ad_id = self.dataArray[indexPath.row].adId
        self.navigationController?.pushViewController(addDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        if collectionView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        
        let objData = AddsHandler.sharedInstance.objMyAds
        let lastElement = dataArray.count - 1
        if indexPath.row == lastElement {
            if (objData?.pagination.hasNextPage)! {
                let param: [String: Any] = ["page_number": objData?.pagination.nextPage]
                self.adForest_loadMoreData(param: param as NSDictionary)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func editProfile(_ sender: Any) {
        let editProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileController") as! EditProfileController
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @IBAction func actionAdPost(_ sender: Any) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    
    //MARK:- API Calls
    
    //Get Favourite Ads Data
    func adForest_favouriteAdsData() {
        self.showLoader()
        AddsHandler.favouriteAds(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.noAddTitle = successResponse.message
                AddsHandler.sharedInstance.objMyAds = successResponse.data
                self.dataArray = successResponse.data.ads
                self.adForest_populateData()
                self.collectionView.reloadData()
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
    
    //Load More Data
    func adForest_loadMoreData(param: NSDictionary) {
        self.showLoader()
        AddsHandler.moreFavouriteData(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                AddsHandler.sharedInstance.objMyAds = successResponse.data
                self.dataArray.append(contentsOf: successResponse.data.ads)
                self.collectionView.reloadData()
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
    
    
    //remove favourite
    func adForest_removeFavourite(param: NSDictionary) {
        self.showLoader()
        AddsHandler.removeFavAdd(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.adForest_favouriteAdsData()
                    self.collectionView.reloadData()
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

class FavouriteCollectionCell: UICollectionViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblAddType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var buttonCancel: UIButton!
    
    //MARK:- Properties
    
    var crossAction: (()->())?
    
    @IBAction func actionCancel(_ sender: Any) {
        crossAction?()
        print("Crossed")
    }
    
}
