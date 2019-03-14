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
    @IBOutlet weak var containerViewIntroduction: UIView!
    @IBOutlet weak var lblIntro: UILabel!
    @IBOutlet weak var containerViewAdds: UIView!
    @IBOutlet weak var lblSoldAds: UILabel!
    @IBOutlet weak var lblAllAds: UILabel!
    @IBOutlet weak var lblInactiveAds: UILabel!
    @IBOutlet weak var lblRatingText: UILabel!
    
    @IBOutlet weak var collectionViewAds: UICollectionView! {
        didSet {
            collectionViewAds.delegate = self
            collectionViewAds.dataSource = self
        }
    }
    
    //MARK:- Properties
    var dataArray = [PublicProfileAdd]()
    
    var userID = ""
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "User Public Profile")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        
        let param: [String: Any] = ["user_id": userID]
        self.adForest_publicProfileData(parameter: param as NSDictionary)
    }
   
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if UserHandler.sharedInstance.objPublicProfile != nil {
            let objData = UserHandler.sharedInstance.objPublicProfile
            
            if let pageTitle = objData?.pageTitle {
                self.title = pageTitle
            }
            
            if let imgUrl = URL(string: (objData?.profileExtra.profileImg)!) {
                self.imgProfile.sd_setImage(with: imgUrl, completed: nil)
                self.imgProfile.sd_setIndicatorStyle(.gray)
                self.imgProfile.sd_setShowActivityIndicatorView(true)
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
                self.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: "#ffcc00")
                self.ratingBar.rating = Double(ratingBar)!
            }
            
            if let ratingText = objData?.profileExtra.rateBar.text {
                self.lblRatingText.text = ratingText
            }
            
            if let introText = objData?.introduction.value {
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
            
        }
        else {
            print("Empty")
        }
    }
    
    private func didTouchCosmos(_ rating: Double) {
        
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
      
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
                cell.imgPic.sd_setImage(with: imgUrl, completed: nil)
                cell.imgPic.sd_setIndicatorStyle(.gray)
                cell.imgPic.sd_setShowActivityIndicatorView(true)
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
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: "#d9534f")
        }
        else if statusType == "active" {
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: "#4caf50")
        }
        else if statusType == "sold" {
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: "#3498db")
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objData = dataArray[indexPath.row]
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        detailVC.ad_id = dataArray[indexPath.row].adId
        self.navigationController?.pushViewController(detailVC, animated: true)
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
        return CGSize(width: 139 * (self.view.frame.size.width/295), height: 190 * (self.view.frame.size.height/568))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
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

