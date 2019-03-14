//
//  AddDetailController.swift
//  AdForest
//
//  Created by apple on 3/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ImageSlideshow
import Alamofire
import AlamofireImage
import MapKit

class AddDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable , SimilarAdsDelegate, ReportPopToHomeDelegate {
  
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            
            let shareNib = UINib(nibName: "ShareCell", bundle: nil)
            tableView.register(shareNib, forCellReuseIdentifier: "ShareCell")
            let descNib = UINib(nibName: "DescriptionCell", bundle: nil)
            tableView.register(descNib, forCellReuseIdentifier: "DescriptionCell")
            let videoNib = UINib(nibName: "YouTubeVideoCell", bundle: nil)
            tableView.register(videoNib, forCellReuseIdentifier: "YouTubeVideoCell")
            let profileNib = UINib(nibName: "AddDetailProfileCell", bundle: nil)
            tableView.register(profileNib, forCellReuseIdentifier: "AddDetailProfileCell")
            let ratingNib = UINib(nibName: "AdRatingCell", bundle: nil)
            tableView.register(ratingNib, forCellReuseIdentifier: "AdRatingCell")
            let bidNib = UINib(nibName: "AddBidsCell", bundle: nil)
            tableView.register(bidNib, forCellReuseIdentifier: "AddBidsCell")
            let replyNib = UINib(nibName: "ReplyCell", bundle: nil)
            tableView.register(replyNib, forCellReuseIdentifier: "ReplyCell")
            let commentNib = UINib(nibName: "CommentCell", bundle: nil)
            tableView.register(commentNib, forCellReuseIdentifier: "CommentCell")
         }
    }
    
    @IBOutlet weak var buttonSendMessage: UIButton! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                buttonSendMessage.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var buttonCallNow: UIButton! {
        didSet {
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                buttonCallNow.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
  
    
    //MARK:- Properties
    let defaults = UserDefaults.standard
    var ad_id = 0
    var isFromMyAds = false
    var isFromInactiveAds = false
    var isFromFeaturedAds = false
    var isFromFavAds = false
    var sendMsgbuttonType = ""
    
    var relatedAdsArray = [AddDetailRelatedAd]()
    var dataArray = [AddDetailData]()
    var fieldsArray = [AddDetailFieldsData]()
    var addVideoArray = [AddDetailAdVideo]()
    var bidsArray = [AddDetailAddBid]()
    var addRatingArray = [AddDetailRating]()
    var addReplyArray = [AddDetailReply]()
    var similarAdsTitle = ""
    var ratingReviewTitle = ""
    var buttonText = ""
    var mutableString = NSMutableAttributedString()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateAddDetails), object: nil, queue: nil) { (notification) in
            let parameter: [String: Any] = ["ad_id": self.ad_id]
            print(parameter)
            self.adForest_addDetail(param: parameter as NSDictionary)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Add Detail Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        
        let parameter: [String: Any] = ["ad_id": ad_id]
        print(parameter)
        self.adForest_addDetail(param: parameter as NSDictionary)
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //Similar Ads Delegate Move Forward From collection View
    
    func goToDetailAd(id: Int) {
        let detailAdVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        detailAdVC.ad_id = id
        self.navigationController?.pushViewController(detailAdVC, animated: true)
    }
    
    //after report add  move to home screen
    func moveToHome(isMove: Bool) {
        if isMove {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func adForest_populateData() {
        if AddsHandler.sharedInstance.objAddDetails != nil {
            let objData = AddsHandler.sharedInstance.objAddDetails
            
            if let msgButtonTitle = objData?.staticText.sendMsgBtn {
                self.buttonSendMessage.setTitle(msgButtonTitle, for: .normal)
            }
            if let callButtonTitle = objData?.staticText.callNowBtn {
                self.buttonCallNow.setTitle(callButtonTitle, for: .normal)
            }
            
            if let msgButtonType = objData?.staticText.sendMsgBtnType {
                self.sendMsgbuttonType = msgButtonType
            }
        }
    }
    
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if section == 2 {
           return 1
        }
        
         if section == 3 {
            if addRatingArray.isEmpty {
                return 0
            }
            else {
                 return addRatingArray.count
            }
        }
        else if section == 4 {
            return addReplyArray.count
        }
        
        else if section == 7 {
            if addVideoArray.isEmpty {
                return 0
            }
            else {
                addVideoArray.count
            }
        }
        else if section == 8 {
            if bidsArray.isEmpty {
                return 0
            }
            else {
                return bidsArray.count
            }
        }
        
        else if section == 9 {
            return 1
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section

        if section == 0 {
            let cell: AddDetailCell = tableView.dequeueReusableCell(withIdentifier: "AddDetailCell", for: indexPath) as! AddDetailCell
            let objData = dataArray[indexPath.row]
            
            if objData.notification == "" {
                cell.viewAddApproval.isHidden = true
                cell.viewFeaturedAdd.translatesAutoresizingMaskIntoConstraints = false
                cell.viewFeaturedAdd.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
            }
            else {
                cell.viewAddApproval.isHidden = false
                if let approvalText = objData.notification {
                    cell.lblAddApproval.text = approvalText
                }
            }
            
            var isShowFeatured = false
            if let isFeature = objData.isFeatured.isShow {
                isShowFeatured = isFeature
            }
            
            if isShowFeatured {
                if let featureText = objData.isFeatured.notification.text {
                    cell.lblFeaturedAdd.text = featureText
                }
                if let buttonFeatureText = objData.isFeatured.notification.btn {
                    cell.buttonFeatured.setTitle(buttonFeatureText, for: .normal)
                }
            }
            else {
                cell.viewFeaturedAdd.isHidden = true
                cell.slideshow.translatesAutoresizingMaskIntoConstraints = false
                cell.slideshow.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
            }
            
            var isFeature = false
            if let featureBool = objData.adDetail.isFeature {
                isFeature = featureBool
            }
            
            if isFeature {
                if let featureText = objData.adDetail.isFeatureText {
                    cell.lblFeatured.backgroundColor = Constants.hexStringToUIColor(hex: "#E52D27")
                    cell.lblFeatured.text = featureText
                }
            }
            else {
                 cell.lblFeatured.isHidden = true
            }

            if let sliderImage = objData.adDetail.images {
                cell.sourceImages = []
                cell.imagesArray = sliderImage
                cell.imageSliderSetting()
            }
            
            cell.btnMakeFeature = { () in
                let param: [String: Any] = ["ad_id": objData.adDetail.adId]
                self.adForest_makeAddFeature(Parameter: param as NSDictionary)
            }

            if let directionButtonTitle = objData.staticText.getDirection {
                cell.oltDirection.setTitle(directionButtonTitle, for: .normal)
            }
            
            cell.oltDirection.backgroundColor = Constants.hexStringToUIColor(hex: "#90000000")
            cell.btnDirectionAction = { () in
                guard let latitude = objData.adDetail.location.lat else {
                    return
                }
                
                guard let longitude =  objData.adDetail.location.longField else {
                    return
                }
                
                let lat = CLLocationDegrees(latitude)
                let long = CLLocationDegrees(longitude)
                
                let regionDistance: CLLocationDistance = 1000
                let coordinates = CLLocationCoordinate2DMake(lat!, long!)
                
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                
                let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan:  regionSpan.span)]
                
                let placeMark = MKPlacemark(coordinate: coordinates)
                let mapItem = MKMapItem(placemark: placeMark)
                mapItem.name = objData.adDetail.locationTop
                mapItem.openInMaps(launchOptions: options)
            }
            return cell
        }
        
        else if section == 1 {
            let cell: ShareCell = tableView.dequeueReusableCell(withIdentifier: "ShareCell", for: indexPath) as! ShareCell
            let objData = dataArray[indexPath.row]
            
            if let addTitleText = objData.adDetail.adTitle {
                cell.lblName.text = addTitleText
            }
            if let date = objData.adDetail.adDate {
                cell.lblDate.text = date
            }
            if let viewCount = objData.adDetail.adViewCount {
                cell.lblLookAdd.text = viewCount
            }
            
            if let locationText = objData.adDetail.locationTop {
                cell.lblLocation.text = locationText
            }
            if let priceText = objData.adDetail.adPrice.price {
                cell.lblPrice.text = priceText
            }
            
            if let shareText = objData.staticText.shareBtn {
                cell.buttonShare.setTitle(shareText, for: .normal)
            }
            if let favouriteText = objData.staticText.favBtn {
                cell.buttonFavourite.setTitle(favouriteText, for: .normal)
            }
            if let reportText = objData.staticText.reportBtn {
                cell.buttonReport.setTitle(reportText, for: .normal)
            }
            
            cell.btnFavouriteAdd = { ()
                if self.defaults.bool(forKey: "isGuest") {
                    if let msg = self.defaults.string(forKey: "notLogin") {
                         self.showToast(message: msg)
                    }
                }
                else {
                    let parameter: [String: Any] = ["ad_id": objData.adDetail.adId]
                    self.adForest_makeAddFavourite(param: parameter as NSDictionary)
                }
            }
            cell.btnReport = {  () in
                if self.defaults.bool(forKey: "isGuest") {
                    if let msg = self.defaults.string(forKey: "notLogin"){
                        self.showToast(message: msg)
                    }
                }
                else {
                    let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportController") as! ReportController
                    reportVC.modalPresentationStyle = .overCurrentContext
                    reportVC.modalTransitionStyle = .crossDissolve
                    AddsHandler.sharedInstance.objReportPopUp = objData.reportPopup
                    reportVC.adID = objData.adDetail.adId
                    reportVC.delegate = self
                    self.presentVC(reportVC)
                }
            }
            cell.btnShare = { () in
                let shareTextArray = [objData.shareInfo.title, objData.shareInfo.link]
                let activityController = UIActivityViewController(activityItems: shareTextArray, applicationActivities: nil)
                self.presentVC(activityController)
            }
            return cell
        }
            
        else if section == 2 {
            let cell: AddDetailDescriptionCell = tableView.dequeueReusableCell(withIdentifier: "AddDetailDescriptionCell", for: indexPath) as! AddDetailDescriptionCell
            let objData = AddsHandler.sharedInstance.objAddDetails
            
            if let descriptionText = objData?.staticText.descriptionTitle {
                cell.lblDescription.text = descriptionText
            }
            if let htmlText = objData?.adDetail.adDesc {
                cell.lblHtmlText.attributedText = htmlText.html2AttributedString
            }
            
            if let tagTitle = objData?.adDetail.adTagsShow.name {
                if let addTags = objData?.adDetail.adTagsShow.value {
                    let tags = ":  \(addTags)"
                    let attributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)]
                    let attributedString = NSMutableAttributedString(string: tagTitle, attributes: attributes)
                    
                    let normalString = NSMutableAttributedString(string: tags)
                    attributedString.append(normalString)
                    cell.lblTagTitle.attributedText = attributedString
                }
            }
            if let locationText = objData?.adDetail.location.title {
                cell.locationTitle.text = locationText
            }
            if let locationValue = objData?.adDetail.location.address {
                cell.locationValue.text = locationValue
            }
            
            cell.fieldsArray = self.fieldsArray
            cell.frame = tableView.bounds
            cell.layoutIfNeeded()
            
            cell.adForest_reload()
            cell.cstCollectionHeight.constant = cell.collectionView.contentSize.height
           // cell.collectionView.reloadData()
            return cell
        }
            
        else if section == 3 {
            let cell: ReplyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell
                let objData = addRatingArray[indexPath.row]
        
                if let imgUrl = URL(string: objData.ratingAuthorImage) {
                    cell.imgProfile.sd_setIndicatorStyle(.gray)
                    cell.imgProfile.sd_setShowActivityIndicatorView(true)
                    cell.imgProfile.sd_setImage(with: imgUrl, completed: nil)
                }
                if let name = objData.ratingAuthorName {
                    cell.lblName.text = name
                }
                if let replyText = objData.ratingText {
                    cell.lblReply.text = replyText
                }
                if let date = objData.ratingDate {
                    cell.lblDate.text = date
                }
                if let ratingBar = objData.ratingStars {
                    cell.ratingBar.settings.updateOnTouch = false
                    cell.ratingBar.settings.fillMode = .precise
                    cell.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: "#ffcc00")
                    cell.ratingBar.rating = Double(ratingBar)!
                }
            if let replyButtontext = objData.replyText {
                cell.oltReply.setTitle(replyButtontext, for: .normal)
            }
            
            if objData.canReply {
                cell.oltReply.isHidden = false
                cell.btnReplyAction = { () in
                    let commentVC = self.storyboard?.instantiateViewController(withIdentifier: "ReplyCommentController") as! ReplyCommentController
                    commentVC.modalPresentationStyle = .overCurrentContext
                    commentVC.modalTransitionStyle = .crossDissolve
                    commentVC.isFromAddDetailReply = true
                    commentVC.objAddDetail = AddsHandler.sharedInstance.objAddDetails?.adRatting.rplyDialog
                    commentVC.comment_id = objData.ratingId
                    commentVC.ad_id = self.ad_id
                    self.presentVC(commentVC)
                }
            }
            else {
                cell.oltReply.isHidden = true
            }
            return cell
        }
        else if section == 4 {
            //reply cell
            let cell : CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let objData = addReplyArray[indexPath.row]
            
            if let imgUrl = URL(string: objData.ratingAuthorImage) {
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
            
            if let name = objData.ratingAuthorName {
                cell.lblName.text = name
            }
            if let date = objData.ratingDate {
                cell.lblDate.text = date
            }
            if let replyText = objData.ratingText {
                cell.lblReply.text = replyText
            }
            return cell
        }
            
            
        else if section == 5 {
            let cell: AdRatingCell = tableView.dequeueReusableCell(withIdentifier: "AdRatingCell", for: indexPath) as! AdRatingCell
            let objData = dataArray[indexPath.row]
            
            if let receiverText = objData.staticText.sendMsgBtnType {
                buttonText = receiverText
            }
            
            if objData.adRatting.canRate && buttonText != "receive" {
                if let title = objData.adRatting.title {
                    cell.lblTitle.text = title
                }
                if let txtPlaceholder = objData.adRatting.textareaText {
                    cell.txtComment.placeholder = txtPlaceholder
                }
                let isShowEditLbl = objData.adRatting.isEditable
                if isShowEditLbl! {
                    cell.lblNotEdit.isHidden = true
                }
                else {
                    if let notEditLblText = objData.adRatting.tagline {
                        cell.lblNotEdit.text = notEditLblText
                    }
                }
                if let submitButtonText = objData.adRatting.btn {
                    cell.oltSubmitRating.setTitle(submitButtonText, for: .normal)
                }
                cell.adID = self.ad_id
                
            }
            else {
                if let noRatingText = objData.adRatting.canRateMsg {
                    cell.lblTitle.text = noRatingText
                    cell.lblTitle.textAlignment = .center
                }
                cell.lblNotEdit.isHidden = true
                cell.txtComment.isHidden = true
                cell.oltSubmitRating.isHidden = true
                cell.ratingBar.isHidden = true
            }
            
            return cell
        }
            
            
        else if section == 6 {
            let cell: AddDetailProfileCell = tableView.dequeueReusableCell(withIdentifier: "AddDetailProfileCell", for: indexPath) as! AddDetailProfileCell
            
            let objData = dataArray[indexPath.row]
            
            if let imgUrl = URL(string: objData.profileDetail.profileImg) {
                cell.imgProfile.sd_setIndicatorStyle(.gray)
                cell.imgProfile.sd_setShowActivityIndicatorView(true)
                cell.imgProfile.sd_setImage(with: imgUrl, completed: nil)
            }
            if let name = objData.profileDetail.displayName {
                cell.lblName.text = name
            }
        
        if let verifyButtonText = objData.profileDetail.verifyButon.text {
            cell.lblType.text = verifyButtonText
        }
        if let buttonColor = objData.profileDetail.verifyButon.color {
            cell.lblType.backgroundColor = Constants.hexStringToUIColor(hex: buttonColor)
        }
        if let loginTime = objData.profileDetail.lastLogin {
            cell.lblLastLogin.text = loginTime
        }
        if let ratingBar = objData.profileDetail.rateBar.number {
            cell.ratingBar.settings.updateOnTouch = false
            cell.ratingBar.settings.fillMode = .precise
            cell.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: "#ffcc00")
            cell.ratingBar.rating = Double(ratingBar)!
        }
            
        if let avgRating = objData.profileDetail.rateBar.text {
            cell.ratingText.text = avgRating
        }
        
            //cell did select action handle in button
            cell.btnCoverAction = { () in
                let publicProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UserPublicProfile") as! UserPublicProfile
                publicProfileVC.userID = objData.adDetail.authorId
                self.navigationController?.pushViewController(publicProfileVC, animated: true)
            }
            
            var isShowBlockButton = false
            if let isShowBtn = objData.staticText.blockUser.isShow {
                isShowBlockButton = isShowBtn
            }
            if isShowBlockButton {
                cell.oltBlockButton.isHidden = false
                
                if let btnTitle = objData.staticText.blockUser.text {
                    cell.oltBlockButton.setTitle(btnTitle, for: .normal)
                }
                var popUpTitle = ""
                var popUpText = ""
                var cancelText = ""
                var confirmText = ""
                var user_id = ""
                
                if let popTitle = objData.staticText.blockUser.text {
                    popUpTitle = popTitle
                }
                if let popText = objData.staticText.blockUser.popupText {
                    popUpText = popText
                }
                if let cancel = objData.staticText.blockUser.popupCancel {
                    cancelText = cancel
                }
                
                if let confirm = objData.staticText.blockUser.popupConfirm {
                    confirmText = confirm
                }
                
                if let id = objData.adDetail.adAuthorId {
                    user_id = id
                }
                
                cell.btnBlock = { () in
                    let alert = UIAlertController(title: popUpTitle, message: popUpText, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: confirmText , style: .default, handler: { (action) in
                        let param: [String: Any] = ["user_id": user_id]
                        print(param)
                        self.adForest_blockUser(param: param as NSDictionary)
                    })
                    let cancelAction = UIAlertAction(title: cancelText, style: .default, handler: nil)
                    
                    alert.addAction(cancelAction)
                    alert.addAction(okAction)
                    self.presentVC(alert)
                }
            }
            else {
                cell.oltBlockButton.isHidden = true
            }
        
        return cell
        }
            
        else if section == 7 {
            let cell: YouTubeVideoCell = tableView.dequeueReusableCell(withIdentifier: "YouTubeVideoCell", for: indexPath) as! YouTubeVideoCell
            let objData = addVideoArray[indexPath.row]
            
            if let videoUrl = objData.videoId {
                cell.playerView.loadVideoID(videoUrl)
            }
            return cell
        }
            
        else if section == 8 {
            let cell: AddBidsCell = tableView.dequeueReusableCell(withIdentifier: "AddBidsCell", for: indexPath) as! AddBidsCell
            let objData = bidsArray[indexPath.row]
            let data = AddsHandler.sharedInstance.objAddDetails
            if (data?.staticText.adBidsEnable)! {
                if let totalText = objData.totalText {
                    cell.lblTotal.text = totalText
                }
                if let totalValue = objData.total {
                    cell.lblTotalValue.text = String(totalValue)
                }
                if let hightText = objData.maxText {
                    cell.lblHighest.text = hightText
                }
                if let highValue = objData.max.price {
                    cell.lblhighestValue.text = highValue
                }
                if let lowText = objData.minText {
                    cell.lblLowest.text = lowText
                }
                if let lowValue = objData.min.price {
                    cell.lblLowestValue.text = lowValue
                }
                
                if let bidText = data?.staticText.bidNowBtn {
                    cell.oltBids.setTitle(bidText, for: .normal)
                }
                if let statText = data?.staticText.bidStatsBtn {
                    cell.oltStats.setTitle(statText, for: .normal)
                }
                cell.btnBids = { () in
                    let bidsVC = self.storyboard?.instantiateViewController(withIdentifier: "BidsController") as! BidsController
                    bidsVC.adID = (data?.adDetail.adId)!
                    AddsHandler.sharedInstance.adIdBidStat = (data?.adDetail.adId)!
                    self.navigationController?.pushViewController(bidsVC, animated: true)
                }
                
                cell.btnStats = { () in
                    let bidsVC = self.storyboard?.instantiateViewController(withIdentifier: "BidsController") as! BidsController
                    bidsVC.adID = (data?.adDetail.adId)!
                    AddsHandler.sharedInstance.adIdBidStat = (data?.adDetail.adId)!
                    self.navigationController?.pushViewController(bidsVC, animated: true)
                }
            }
            else {
                cell.containerView.isHidden = true
            }
            return cell
        }
            
        else if section == 9 {
            let cell : SimilarAdsTableCell = tableView.dequeueReusableCell(withIdentifier: "SimilarAdsTableCell", for: indexPath) as! SimilarAdsTableCell
            
            cell.relatedAddsArray = self.relatedAdsArray
            cell.delegate = self
            cell.collectionView.reloadData()
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        var height: CGFloat = 0
        
        if section == 0 {
            let objData = dataArray[indexPath.row]
            let isFeatured = objData.isFeatured.isShow
            if isFeatured! {
                height = 300
            }
            else if isFeatured == false {
                height = 270
            }
        }
            
        else if section == 1 {
            height = 185
        }
            
        else if section == 2 {
            height = UITableViewAutomaticDimension
        }
            
        else if section == 3 {
            if addRatingArray.count == 0 {
                height = 30
            }
            else {
                 height = UITableViewAutomaticDimension
            }
           
        }
        else if section == 4 {
            height = UITableViewAutomaticDimension
        }
            
        else if section == 5 {
            let objData = dataArray[indexPath.row]
            if objData.adRatting.canRate && buttonText != "receive"  {
              height = 220
            }
            else {
                height = 50
            }
        }
            
        else if section == 6 {
           height = 110
        }
            
        else if section == 7 {
            let objdata = addVideoArray[indexPath.row]
            if objdata.videoId == "" {
                height = 0
            }
            else {
                 height = 230
            }
        }
        else if section == 8 {
         let isBidEnable = AddsHandler.sharedInstance.objAddDetails?.staticText.adBidsEnable
            if isBidEnable! {
                height = 120
            }
            else {
                height = 0
            }
        }

        else if section == 9 {
            height = 230
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0.0

        if section == 3 {
            height = 20
        }
        else if section == 9 {
            height = 20
        }
        return height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width - 20, height: 20))
       
        if section == 3 {
            titleLabel.text = ratingReviewTitle
             titleLabel.textAlignment = .center
        }
        else if section == 9 {
            titleLabel.text = similarAdsTitle
            titleLabel.textAlignment = .left
        }
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    //MARK:- IBActions
    
    
    @IBAction func actionSendMessage(_ sender: Any) {
        if defaults.bool(forKey: "isGuest") {
            if let msg = defaults.string(forKey: "notLogin") {
                self.showToast(message: msg)
            }
        }
        else {
            if sendMsgbuttonType == "receive" {
                let msgVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesController") as! MessagesController
                msgVC.isFromAdDetail = true
                self.navigationController?.pushViewController(msgVC, animated: true)
            }
            else {
                let sendMsgVC = self.storyboard?.instantiateViewController(withIdentifier: "ReplyCommentController") as! ReplyCommentController
                sendMsgVC.modalPresentationStyle = .overCurrentContext
                sendMsgVC.modalTransitionStyle = .flipHorizontal
                sendMsgVC.isFromMsg = true
                sendMsgVC.objAddDetailData = AddsHandler.sharedInstance.objAddDetails
                self.present(sendMsgVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionCallNow(_ sender: Any) {
        let sendMsgVC = self.storyboard?.instantiateViewController(withIdentifier: "ReplyCommentController") as! ReplyCommentController
        sendMsgVC.modalPresentationStyle = .overCurrentContext
        sendMsgVC.modalTransitionStyle = .flipHorizontal
        sendMsgVC.isFromCall = true
        sendMsgVC.objAddDetailData = AddsHandler.sharedInstance.objAddDetails
        self.present(sendMsgVC, animated: true, completion: nil)
    }
    
    
    //MARK:- API Call
    
    func adForest_addDetail(param: NSDictionary) {
        self.showLoader()
        AddsHandler.addDetails(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            print(successResponse.data)
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                AddsHandler.sharedInstance.descTitle = successResponse.data.staticText.descriptionTitle
                AddsHandler.sharedInstance.htmlText = successResponse.data.adDetail.adDesc
                self.similarAdsTitle = successResponse.data.staticText.relatedPostsTitle
                
                //to get images in image slider on first section
//                for image in successResponse.data.adDetail.images {
//                    AddsHandler.sharedInstance.objAddDetailImage = image.
//                }
                
                // set bid & stat title to show in bidding xlpager title
                AddsHandler.sharedInstance.bidTitle = successResponse.data.staticText.bidTabs.bid
                AddsHandler.sharedInstance.statTitle = successResponse.data.staticText.bidTabs.stats
                
                self.addRatingArray = successResponse.data.adRatting.ratings
                //set rating section title
                if self.addRatingArray.count == 0 {
                      self.ratingReviewTitle = successResponse.data.adRatting.noRatingMessage
                }
                else {
                      self.ratingReviewTitle = successResponse.data.adRatting.sectionTitle
                }
                
                for replys in successResponse.data.adRatting.ratings {
                    self.addReplyArray = replys.reply
                }
                
                AddsHandler.sharedInstance.objAddDetails = successResponse.data
                self.bidsArray = [successResponse.data.staticText.adBids]
                self.addVideoArray = [successResponse.data.adDetail.adVideo]
                self.dataArray = [successResponse.data]
                self.fieldsArray = successResponse.data.adDetail.fieldsData
                self.relatedAdsArray = successResponse.data.adDetail.relatedAds
                self.adForest_populateData()
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
    
    //Make Add Feature
    
    func adForest_makeAddFeature(Parameter: NSDictionary) {
        self.showLoader()
        AddsHandler.makeAddFeature(parameter: Parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    let parameter: [String: Any] = ["ad_id": self.ad_id]
                    self.adForest_addDetail(param: parameter as NSDictionary)
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
    
    
    //Make Add Favourite
    
    func adForest_makeAddFavourite(param: NSDictionary) {
        self.showLoader()
        AddsHandler.makeAddFavourite(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
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
    
    //Block user
    func adForest_blockUser(param: NSDictionary) {
        self.showLoader()
        UserHandler.blockUser(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.navigationController?.popViewController(animated: true)
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


class AddDetailCell: UITableViewCell {
    
    @IBOutlet weak var viewAddApproval: UIView!
    @IBOutlet weak var lblAddApproval: UILabel!
    @IBOutlet weak var viewFeaturedAdd: UIView!
    @IBOutlet weak var lblFeaturedAdd: UILabel!
    @IBOutlet weak var buttonFeatured: UIButton! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                buttonFeatured.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var lblFeatured: UILabel!
    @IBOutlet weak var oltDirection: UIButton!
    
    //MARK:- Properties
    
    var btnMakeFeature: (()->())?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imagesArray = [AddDetailImage]()
    var objImage : AddDetailImage?
    var isFeature = false
    var featureText = ""
    var stringValue = ""
    var btnDirectionAction: (()->())?
    var sourceImages = [InputSource]()
    
    //MARK:- Properties
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
   
    func imageSliderSetting() {
        for image in imagesArray {
            let alamofireSource = AlamofireSource(urlString: image.full)!
            sourceImages.append(alamofireSource)
        }
        slideshow.backgroundColor = UIColor.white
        slideshow.slideshowInterval = 5.0
        slideshow.pageControlPosition = PageControlPosition.insideScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.white
        slideshow.pageControl.pageIndicatorTintColor = UIColor.lightGray
        slideshow.contentScaleMode = UIViewContentMode.scaleToFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.currentPageChanged = { page in
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(sourceImages)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        slideshow.addGestureRecognizer(recognizer)
    }
  
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: viewController()!)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    //MARK:- IBActions
    @IBAction func actionFeatured(_ sender: UIButton) {
        self.btnMakeFeature?()
    }
    
    
    @IBAction func actionDirection(_ sender: Any) {
        self.btnDirectionAction?()
    }
}
