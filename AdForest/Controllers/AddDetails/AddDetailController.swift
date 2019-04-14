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

class AddDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable , SimilarAdsDelegate, ReportPopToHomeDelegate, moveTomessagesDelegate {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            
            tableView.register(UINib(nibName: "ShareCell", bundle: nil), forCellReuseIdentifier: "ShareCell")
            tableView.register(UINib(nibName: "YouTubeVideoCell", bundle: nil), forCellReuseIdentifier: "YouTubeVideoCell")
            tableView.register(UINib(nibName: "AddDetailProfileCell", bundle: nil), forCellReuseIdentifier: "AddDetailProfileCell")
            tableView.register(UINib(nibName: "AdRatingCell", bundle: nil), forCellReuseIdentifier: "AdRatingCell")
            tableView.register(UINib(nibName: "AddBidsCell", bundle: nil), forCellReuseIdentifier: "AddBidsCell")
            tableView.register(UINib(nibName: "ReplyCell", bundle: nil), forCellReuseIdentifier: "ReplyCell")
            tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
            tableView.register(UINib(nibName: "LoadMoreCell", bundle: nil), forCellReuseIdentifier: "LoadMoreCell")
        }
    }
    
    @IBOutlet weak var containerViewbutton: UIView!
    
    @IBOutlet weak var buttonSendMessage: UIButton! {
        didSet {
            buttonSendMessage.isHidden = true
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                buttonSendMessage.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var buttonCallNow: UIButton! {
        didSet {
            buttonCallNow.isHidden = true
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                buttonCallNow.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    @IBOutlet weak var imgMessage: UIImageView! {
        didSet{
            imgMessage.isHidden = true
            imgMessage.image = imgMessage.image?.withRenderingMode(.alwaysTemplate)
            imgMessage.tintColor = .white
        }
    }
    @IBOutlet weak var imgCall: UIImageView! {
        didSet {
            imgCall.isHidden = true
            imgCall.image = imgCall.image?.withRenderingMode(.alwaysTemplate)
            imgCall.tintColor = .white
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
    var similarAdsTitle = ""
    var ratingReviewTitle = ""
    var buttonText = ""
    var isShowAdTime = false
    
    var day: Int = 0
    var hour: Int = 0
    var minute: Int = 0
    var second: Int = 0
    var serverTime = ""
    
    var relatedAdsArray = [AddDetailRelatedAd]()
    var dataArray = [AddDetailData]()
    var fieldsArray = [AddDetailFieldsData]()
    var addVideoArray = [AddDetailAdVideo]()
    var bidsArray = [AddDetailAddBid]()
    var addRatingArray = [AddDetailRating]()
    var addReplyArray = [AddDetailReply]()
    var mutableString = NSMutableAttributedString()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.hideKeyboard()
        self.adMob()
        self.googleAnalytics(controllerName: "Add Detail Controller")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateAddDetails), object: nil, queue: nil) { (notification) in
            let parameter: [String: Any] = ["ad_id": self.ad_id]
            print(parameter)
            self.adForest_addDetail(param: parameter as NSDictionary)
        }
        let parameter: [String: Any] = ["ad_id": ad_id]
        print(parameter)
        self.adForest_addDetail(param: parameter as NSDictionary)
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //MARK:- After Message Sent, Move to messages Screen
    func isMoveMessages(isMove: Bool) {
        let messagesVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesController") as! MessagesController
        messagesVC.isFromAdDetail = true
        self.navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    //MARK:- Similar Ads Delegate Move Forward From collection View
    func goToDetailAd(id: Int) {
        let detailAdVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        detailAdVC.ad_id = id
        self.navigationController?.pushViewController(detailAdVC, animated: true)
    }
    
    //MARK:- after report add  move to home screen
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
            
            guard let isShowCallButton = objData?.staticText.showCallBtn else {return}
            guard let isShowMsgButton = objData?.staticText.showMegsBtn else {return}
            
            if isShowMsgButton && isShowCallButton == false {
                imgCall.isHidden = true
                imgMessage.isHidden = false
                buttonCallNow.isHidden = true
                buttonSendMessage.isHidden = false
                buttonSendMessage.translatesAutoresizingMaskIntoConstraints = false
                buttonSendMessage.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
                buttonSendMessage.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
            } else if isShowMsgButton == false && isShowCallButton {
                imgCall.isHidden = false
                imgMessage.isHidden = true
                buttonSendMessage.isHidden = true
                buttonCallNow.isHidden = false
                buttonCallNow.translatesAutoresizingMaskIntoConstraints = false
                buttonCallNow.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
                buttonCallNow.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
                
                imgCall.translatesAutoresizingMaskIntoConstraints = false
                imgCall.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8).isActive = true
            } else if isShowMsgButton && isShowCallButton {
                buttonSendMessage.isHidden = false
                buttonCallNow.isHidden = false
                imgCall.isHidden = false
                imgMessage.isHidden = false
            }
        }
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
                        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
                        SwiftyAd.shared.showBanner(from: self, at: .top)
                    } else {
                        self.containerViewbutton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 60).isActive = true
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
    //MARK:- Counter
    func countDown(date: String) {
        let calendar = Calendar.current
        let requestComponents = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .nanosecond])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeNow = Date()
        let endTime = dateFormatter.date(from: date)
        let timeDifference = calendar.dateComponents(requestComponents, from: timeNow, to: endTime!)
        day  = timeDifference.day!
        hour = timeDifference.hour!
        minute = timeDifference.minute!
        second = timeDifference.second!
    }
    
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2 {
            return 1
        }
        else if section == 3 {
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
        else if section == 5 {
            return 1
        }
            
        else if section == 8 {
            if addVideoArray.isEmpty {
                return 0
            }
            else {
                return addVideoArray.count
            }
        }
        else if section == 9 {
            if bidsArray.isEmpty {
                return 0
            }
            else {
                return bidsArray.count
            }
        }
        else if section == 10 {
            return 1
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddDetailCell", for: indexPath) as! AddDetailCell
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
            if let sliderImage = objData.adDetail.sliderImages {
                cell.localImages = []
                cell.localImages = sliderImage
                cell.imageSliderSetting()
            }
            cell.btnMakeFeature = { () in
                let param: [String: Any] = ["ad_id": objData.adDetail.adId]
                self.adForest_makeAddFeature(Parameter: param as NSDictionary)
            }
            if let directionButtonTitle = objData.staticText.getDirection {
                cell.oltDirection.setTitle(directionButtonTitle, for: .normal)
            }
            cell.oltDirection.backgroundColor = Constants.hexStringToUIColor(hex: Constants.AppColor.brownColor)
            
            var latitude = ""
            var longitude = ""
            
            if let lat = objData.adDetail.location.lat {
                latitude = lat
            }
            if let long = objData.adDetail.location.longField {
                longitude = long
            }
            if latitude == "" && longitude == "" {
                cell.oltDirection.isHidden = true
            } else {
                cell.oltDirection.isHidden = false
                cell.btnDirectionAction = { () in
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
            }
            if isShowAdTime {
                cell.lblTimer.isHidden = false
                let obj = AddsHandler.sharedInstance.adBidTime
                if let endDate = obj?.timerTime {
                    Timer.every(1.second) {
                        self.countDown(date: endDate)
                        cell.lblTimer.text = "\(self.day) D: \(self.hour) H: \(self.minute) M: \(self.second) S"
                    }
                }
            } else {
                cell.lblTimer.isHidden = true
            }
            return cell
        }
            
        else if section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCell", for: indexPath) as! ShareCell
            let objData = dataArray[indexPath.row]
            var isShowAdType = false
            if let isShow = objData.adDetail.adTypeBar.isShow {
                isShowAdType = isShow
            }
            if isShowAdType {
                if let saleType = objData.adDetail.adTypeBar.text {
                    cell.imgBell.isHidden = false
                    cell.lblType.text = saleType
                }
            } else {
                cell.imgBell.isHidden = true
            }
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
                //cell.buttonShare.setTitle(shareText, for: .normal)
                cell.lblShareOrig.text = shareText
            }
            if let favouriteText = objData.staticText.favBtn {
                //cell.buttonFavourite.setTitle(favouriteText, for: .normal)
                cell.lblShare.text = favouriteText
            }
            if let reportText = objData.staticText.reportBtn {
                //cell.buttonReport.setTitle(reportText, for: .normal)
                cell.lblReport.text = reportText
            }
            cell.btnFavouriteAdd = { ()
                if self.defaults.bool(forKey: "isLogin") == false {
                    if let msg = self.defaults.string(forKey: "notLogin") {
                        self.showToast(message: msg)
                    }
                }
                else {
                    let parameter: [String: Any] = ["ad_id": objData.adDetail.adId]
                    self.adForest_makeAddFavourite(param: parameter as NSDictionary)
                }
            }
            cell.btnReport = { () in
                if self.defaults.bool(forKey: "isLogin") == false {
                    if let msg = self.defaults.string(forKey: "notLogin"){
                        self.showToast(message: msg)
                    }
                } else if objData.staticText.sendMsgBtnType == "receive" {
                    if let reportText = objData.cantReportTxt {
                        self.showToast(message: reportText)
                    }
                } else {
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
            
            if objData.staticText.sendMsgBtnType == "receive" {
                if self.defaults.bool(forKey: "isLogin") == false {
                    cell.containerViewEdit.isHidden = true
                } else {
                    cell.containerViewEdit.isHidden = false
                    cell.btnEdit = { () in
                        let editAdVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
                        editAdVC.isFromEditAd = true
                        editAdVC.ad_id = self.ad_id
                        self.navigationController?.pushViewController(editAdVC, animated: true)
                    }
                }
            } else {
                 cell.containerViewEdit.isHidden = true
            }
            return cell
        }
            
        else if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddDetailDescriptionCell", for: indexPath) as! AddDetailDescriptionCell
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
            cell.adForest_reload()
            cell.layoutIfNeeded()
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
                cell.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: Constants.AppColor.ratingColor)
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
            let objData = AddsHandler.sharedInstance.objAddDetails
            var hasNextPage = false
            if let hasPage = objData?.adRatting.pagination.hasNextPage {
                hasNextPage = hasPage
            }
            if hasNextPage {
                let cell: LoadMoreCell =  tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as! LoadMoreCell
                let objData = AddsHandler.sharedInstance.objAddDetails
                if let loadMoreButton = objData?.adRatting.loadmoreBtn {
                    cell.oltLoadMore.setTitle(loadMoreButton, for: .normal)
                }
                cell.btnLoadMore = { () in
                    let ratingVC = self.storyboard?.instantiateViewController(withIdentifier: "RatingReviewsController") as! RatingReviewsController
                    ratingVC.adID = self.ad_id
                    self.navigationController?.pushViewController(ratingVC, animated: true)
                }
                return cell
            }
        }
        else if section == 6 {
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
                cell.btnSubmitAction = { () in
                    guard let comment = cell.txtComment.text else {return}
                    if comment == "" {
                        cell.txtComment.shake(6, withDelta: 10, speed: 0.06)
                    } else {
                        let param: [String: Any] = ["ad_id": self.ad_id, "rating": cell.rating, "rating_comments": comment]
                        print(param)
                        self.adForest_addRating(param: param as NSDictionary)
                    }
                }
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
        else if section == 7 {
            let cell: AddDetailProfileCell = tableView.dequeueReusableCell(withIdentifier: "AddDetailProfileCell", for: indexPath) as! AddDetailProfileCell
    
            let objData = dataArray[indexPath.row]
            if let imgUrl = URL(string: objData.profileDetail.profileImg) {
                cell.imgProfile.sd_setShowActivityIndicatorView(true)
                cell.imgProfile.sd_setIndicatorStyle(.gray)
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
                cell.ratingBar.settings.filledColor = Constants.hexStringToUIColor(hex: Constants.AppColor.ratingColor)
                cell.ratingBar.rating = Double(ratingBar)!
            }
            
            if let avgRating = objData.profileDetail.rateBar.text {
                cell.ratingBar.text = avgRating
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
            cell.btnUserProfileAction = { () in
                if self.defaults.bool(forKey: "isLogin") == false {
                    if let msg = self.defaults.string(forKey: "notLogin") {
                        self.showToast(message: msg)
                    }
                } else {
                    guard let id = objData.adDetail.adAuthorId else {return}
                    let ratingVC = self.storyboard?.instantiateViewController(withIdentifier: "PublicUserRatingController") as! PublicUserRatingController
                    ratingVC.adAuthorID = id
                    self.navigationController?.pushViewController(ratingVC, animated: true)
                }
            }
            return cell
        }
            
        else if section == 8 {
            let cell: YouTubeVideoCell = tableView.dequeueReusableCell(withIdentifier: "YouTubeVideoCell", for: indexPath) as! YouTubeVideoCell
            let objData = addVideoArray[indexPath.row]
            
            if let videoUrl = objData.videoId {
                cell.playerView.loadVideoID(videoUrl)
            }
            return cell
        }
            
        else if section == 9 {
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
            
        else if section == 10 {
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
            height = 210
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
            let objData = AddsHandler.sharedInstance.objAddDetails
            var hasNextPage = false
            if let hasPage = objData?.adRatting.pagination.hasNextPage {
                hasNextPage = hasPage
            }
            if hasNextPage {
                height = 50
            } else {
                height = 0
            }
        }
        else if section == 6 {
            let objData = dataArray[indexPath.row]
            if objData.adRatting.canRate && buttonText != "receive"  {
                height = 220
            } else {
                height = 50
            }
        }
            
        else if section == 7 {
            height = 105
        }
            
        else if section == 8 {
            let objdata = addVideoArray[indexPath.row]
            if objdata.videoId == "" {
                height = 0
            }
            else {
                height = 230
            }
        }
        else if section == 9 {
            let isBidEnable = AddsHandler.sharedInstance.objAddDetails?.staticText.adBidsEnable
            if isBidEnable! {
                height = 120
            }
            else {
                height = 0
            }
        }
            
        else if section == 10 {
            height = 230
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0.0
        
        if section == 3 {
            height = 20
        }
        else if section == 10 {
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
        else if section == 10 {
            titleLabel.text = similarAdsTitle
            titleLabel.textAlignment = .left
        }
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    //MARK:- IBActions
    
    
    @IBAction func actionSendMessage(_ sender: Any) {
        if defaults.bool(forKey: "isLogin") == false {
            if let msg = defaults.string(forKey: "notLogin") {
                let alert = Constants.showBasicAlert(message: msg)
                self.presentVC(alert)
            }
        } else {
            if sendMsgbuttonType == "receive" {
                let msgVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesController") as! MessagesController
                msgVC.isFromAdDetail = true
                self.navigationController?.pushViewController(msgVC, animated: true)
            } else {
                let sendMsgVC = self.storyboard?.instantiateViewController(withIdentifier: "ReplyCommentController") as! ReplyCommentController
                sendMsgVC.modalPresentationStyle = .overCurrentContext
                sendMsgVC.modalTransitionStyle = .flipHorizontal
                sendMsgVC.isFromMsg = true
                sendMsgVC.objAddDetailData = AddsHandler.sharedInstance.objAddDetails
                sendMsgVC.delegate = self
                self.present(sendMsgVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func actionCallNow(_ sender: UIButton) {
        if (AddsHandler.sharedInstance.objAddDetails?.showPhoneToLogin)! && defaults.bool(forKey: "isAppOpen") {
            if let notLoginMessage = defaults.string(forKey: "notLogin") {
                self.showToast(message: notLoginMessage)
            }
        } else {
            let sendMsgVC = self.storyboard?.instantiateViewController(withIdentifier: "ReplyCommentController") as! ReplyCommentController
            sendMsgVC.modalPresentationStyle = .overCurrentContext
            sendMsgVC.modalTransitionStyle = .coverVertical
            sendMsgVC.isFromCall = true
            sendMsgVC.objAddDetailData = AddsHandler.sharedInstance.objAddDetails
            self.presentVC(sendMsgVC)
        }
    }
    
    //MARK:- API Call
    func adForest_addDetail(param: NSDictionary) {
        self.showLoader()
        AddsHandler.addDetails(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                AddsHandler.sharedInstance.descTitle = successResponse.data.staticText.descriptionTitle
                AddsHandler.sharedInstance.htmlText = successResponse.data.adDetail.adDesc
                self.similarAdsTitle = successResponse.data.staticText.relatedPostsTitle
                
                // set bid & stat title to show in bidding XLPager title
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
                if let adTime = successResponse.data.adDetail.adTimer.isShow {
                    self.isShowAdTime = adTime
                }
                if self.isShowAdTime {
                    AddsHandler.sharedInstance.adBidTime = successResponse.data.adDetail.adTimer
                    self.serverTime = successResponse.data.adDetail.adTimer.timerServerTime
                }
                AddsHandler.sharedInstance.objAddDetails = successResponse.data
                self.bidsArray = [successResponse.data.staticText.adBids]
                self.addVideoArray = [successResponse.data.adDetail.adVideo]
                self.dataArray = [successResponse.data]
                self.fieldsArray = successResponse.data.adDetail.fieldsData
                self.relatedAdsArray = successResponse.data.adDetail.relatedAds
                AddsHandler.sharedInstance.ratingsAdds = successResponse.data.adRatting
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
    
    // Add Rating
    func adForest_addRating(param: NSDictionary) {
        self.showLoader()
        AddsHandler.ratingToAdd(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    let parameter: [String: Any] = ["ad_id": self.ad_id]
                    print(parameter)
                    self.adForest_addDetail(param: parameter as NSDictionary)
                })
                self.presentVC(alert)
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
}
