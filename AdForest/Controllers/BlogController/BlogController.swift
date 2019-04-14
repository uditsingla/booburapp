//
//  BlogController.swift
//  AdForest
//
//  Created by apple on 3/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView

class BlogController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            let nib = UINib(nibName: "BlogCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "BlogCell")
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
    var dataArray = [BlogPost]()
    var currentPage = 0
    var maximumPage = 0
    let defaults = UserDefaults.standard
    var isFromHomeBlog = false
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.googleAnalytics(controllerName: "Blog Controller")
        self.adMob()
        if defaults.bool(forKey: "isRtl") {
            if isFromHomeBlog {
                self.showBackButton()
            }else {
                 self.addRightBarButtonWithImage(#imageLiteral(resourceName: "menu"))
            }
        }
        else {
            if isFromHomeBlog {
                self.showBackButton()
            }
            else {
                self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
            }
        }
        self.adForest_blogData()
        if defaults.bool(forKey: "isGuest") {
            self.oltAdPost.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlogCell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! BlogCell
        let objData = dataArray[indexPath.row]
        
        if objData.hasImage {
            if let imgUrl = URL(string: objData.image) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
        }
        else if objData.hasImage == false {
            cell.imgPicture.isHidden = true
        }
        if let postTitle = objData.title {
            cell.lblName.text = postTitle
        }
        let comments = objData.comments
        
        if comments == nil {
            cell.lblRating.text = "0"
        }
        else {
            cell.lblRating.text = comments
        }

        if let date = objData.date {
            cell.lblDate.text = date
        }
        if let readMoreText = objData.readMore {
            cell.lblReadMore.text = readMoreText
        }
        if let mainColor = defaults.string(forKey: "mainColor") {
            cell.lblReadMore.textColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blogDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BlogDetailController") as! BlogDetailController
        blogDetailVC.post_id = dataArray[indexPath.row].postId
        self.navigationController?.pushViewController(blogDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        
        if indexPath.row == dataArray.count - 1 && currentPage < maximumPage {
            currentPage = currentPage + 1
            let param: [String: Any] = ["page_number": currentPage]
            self.adForest_loadMoreData(param: param as NSDictionary)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let objData = dataArray[indexPath.row]
        var height: CGFloat = 0.0
        if objData.hasImage {
            height = 230
        }
        else if objData.hasImage == false {
            height = 70
        }
        return height
    }
    
    //MARK:- IBActions
    @IBAction func actionAdPost(_ sender: Any) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    //MARK:- API Call
    
    func adForest_blogData() {
        self.showLoader()
        UserHandler.blogData(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.extra.pageTitle
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                self.dataArray = successResponse.data.post
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
    
    //more blog data
    
    func adForest_loadMoreData(param: NSDictionary) {
        self.showLoader()
        UserHandler.moreBlogData(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                self.dataArray.append(contentsOf: successResponse.data.post)
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
}
