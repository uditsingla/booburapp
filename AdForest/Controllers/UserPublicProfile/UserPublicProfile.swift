//
//  UserPublicProfile.swift
//  AdForest
//
//  Created by apple on 4/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import Cosmos
import NVActivityIndicatorView

class UserPublicProfile: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {

    //MARK:- Outlets
    @IBOutlet weak var scrollBar: UIScrollView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var containerViewProfile: UIView! {
        didSet {
            containerViewProfile.addShadowToView()
        }
    }
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVerification: UILabel!
    @IBOutlet weak var lblLastLogin: UILabel!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var containerViewIntroduction: UIView!{
        didSet{
            if let mainColor = self.defaults.string(forKey: "mainColor"){
                self.containerViewIntroduction.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var lblIntro: UILabel!
    @IBOutlet weak var containerViewAdds: UIView!
    @IBOutlet weak var lblSoldAds: UILabel!
    @IBOutlet weak var lblAllAds: UILabel!
    @IBOutlet weak var lblInactiveAds: UILabel!
    @IBOutlet weak var collectionViewAds: UICollectionView! {
        didSet {
            collectionViewAds.delegate = self
            collectionViewAds.dataSource = self
        }
    }
    
    //MARK:- Properties
    var dataArray = [PublicProfileAdd]()
    let defaults = UserDefaults.standard
    var userID = ""
    var authorID = 0
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.adMob()
        self.googleAnalytics(controllerName: "User Public Profile")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let param: [String: Any] = ["user_id": userID]
        self.adForest_publicProfileData(parameter: param as NSDictionary)
    }
    
    //MARK: - Custom
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

                    if objData?.position == "top" {
                        self.containerViewProfile.translatesAutoresizingMaskIntoConstraints = false
                        self.containerViewProfile.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
                        SwiftyAd.shared.showBanner(from: self, at: .top)
                    }
                    else {
                        self.collectionViewAds.translatesAutoresizingMaskIntoConstraints = false
                        self.collectionViewAds.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 50).isActive = true
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
    
    
    func adForest_populateData() {
        if UserHandler.sharedInstance.objPublicProfile != nil {
            let objData = UserHandler.sharedInstance.objPublicProfile
            
            if let pageTitle = objData?.pageTitle {
                self.title = pageTitle
            }
            if let imgUrl = URL(string: (objData?.profileExtra.profileImg)!) {
                self.imgProfile.sd_setShowActivityIndicatorView(true)
                self.imgProfile.sd_setIndicatorStyle(.gray)
                self.imgProfile.sd_setImage(with: imgUrl, completed: nil)
            }
            if let name = objData?.profileExtra.displayName {
                self.lblName.text = name
            }
            if let isVerified = objData?.profileExtra.verifyButon.text {
                self.lblVerification.text = isVerified
                self.lblVerification.backgroundColor = Constants.hexStringToUIColor(hex: (objData?.profileExtra.verifyButon.color)!)
            }
            if let loginTime = objData?.profileExtra.lastLogin {
                self.lblLastLogin.text = loginTime
            }
            if let ratingBar = objData?.profileExtra.rateBar.number {
                self.ratingBar.settings.updateOnTouch = false
                self.ratingBar.settings.fillMode = .precise
                self.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: Constants.AppColor.ratingColor)
                self.ratingBar.rating = Double(ratingBar)!
            }
            
            if let ratingText = objData?.profileExtra.rateBar.text {
                self.ratingBar.text = ratingText
            }
            
            guard let introText = objData?.introduction.value else {return}
            
            if introText == "" {
                containerViewIntroduction.isHidden = true
                containerViewAdds.translatesAutoresizingMaskIntoConstraints = false
                containerViewAdds.topAnchor.constraint(equalTo: self.containerViewProfile.bottomAnchor, constant: 8).isActive = true
            } else {
                self.lblIntro.text = introText
            }
          
            if let soldAds = objData?.profileExtra.adsSold {
                self.lblSoldAds.text = soldAds
            }
            if let allAds = objData?.profileExtra.adsTotal {
                self.lblAllAds.text = allAds
            }
            if let inactiveAds = objData?.profileExtra.adsInactive {
                self.lblInactiveAds.text = inactiveAds
            }
            for authorid in (objData?.ads)! {
                if let author_id = authorid.adAuthorId {
                    self.authorID = author_id
                    break
                }
            }
        }
        else {
            print("Empty")
        }
    }
    
    //MARK:- Collection View Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PublicProfileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PublicProfileCell", for: indexPath) as! PublicProfileCell
        let objData = dataArray[indexPath.row]
        
        for image in objData.adImages {
            if let imgUrl = URL(string: image.thumb) {
                cell.imgPic.sd_setShowActivityIndicatorView(true)
                cell.imgPic.sd_setIndicatorStyle(.gray)
                cell.imgPic.sd_setImage(with: imgUrl, completed: nil)
            }
        }
        
        if let name = objData.adTitle {
            cell.lblName.text = name
        }
        if let price = objData.adPrice.price {
            cell.lblPrice.text = price
        }
        if let addStatus = objData.adStatus.statusText {
            cell.lblType.text = addStatus
        }
        
        let statusType = objData.adStatus.status
        
        if statusType == "expired" {
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: Constants.AppColor.expired)
        }
        else if statusType == "active" {
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: Constants.AppColor.active)
        }
        else if statusType == "sold" {
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: Constants.AppColor.sold)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        detailVC.ad_id = dataArray[indexPath.row].adId
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.isiPadDevice {
            let width = collectionView.bounds.width/3.0
            return CGSize(width: width, height: 200)
        }
        let width = collectionView.bounds.width/2.0
        return CGSize(width: width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
       let objData = UserHandler.sharedInstance.objPublicProfile
        var currentPage = objData?.pagination.currentPage
        let maximumPage = objData?.pagination.maxNumPages
        
        var user_id = ""
        if let userId = objData?.profileExtra.id {
            user_id = userId
        }
        
        if indexPath.row == dataArray.count - 1 && currentPage! < maximumPage! {
            currentPage = currentPage! + 1
            let param: [String: Any] = ["user_id": user_id ,"page_number": currentPage!]
            print(param)
            self.adForest_loadMoreData(parameter: param as NSDictionary)
        }
    }
    
    //MARK:- IBActions
    @IBAction func actionProfileRating(_ sender: Any) {
        let ratingVC = self.storyboard?.instantiateViewController(withIdentifier: "PublicUserRatingController") as! PublicUserRatingController
        ratingVC.adAuthorID = String(authorID)
        self.navigationController?.pushViewController(ratingVC, animated: true)
    }
    
    //MARK:- Api Calls
    func adForest_publicProfileData(parameter: NSDictionary) {
        self.showLoader()
        UserHandler.userPublicProfile(params: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                print(successResponse.data)
                self.dataArray = successResponse.data.ads
                UserHandler.sharedInstance.objPublicProfile = successResponse.data
                self.adForest_populateData()
                self.collectionViewAds.reloadData()
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
    
    func adForest_loadMoreData(parameter: NSDictionary) {
        self.showLoader()
        UserHandler.userPublicProfile(params: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                print(successResponse.data)
                self.dataArray.append(contentsOf: successResponse.data.ads )
                UserHandler.sharedInstance.objPublicProfile = successResponse.data
                self.adForest_populateData()
                self.collectionViewAds.reloadData()
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

