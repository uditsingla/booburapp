//
//  HomeController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseCore
import FirebaseInstanceID
import GoogleMobileAds

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, AddDetailDelegate, CategoryDetailDelegate, UISearchBarDelegate, MessagingDelegate,UNUserNotificationCenterDelegate, NearBySearchDelegate, BlogDetailDelegate , LocationCategoryDelegate, SwiftyAdDelegate , GADInterstitialDelegate, UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: "SearchSectionCell", bundle: nil), forCellReuseIdentifier: "SearchSectionCell")
        }
    }
    @IBOutlet weak var oltAddPost: UIButton! {
        didSet {
            oltAddPost.circularButton()
            if let bgColor = defaults.string(forKey: "mainColor") {
                oltAddPost.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    
    //MARK:- Properties
    var defaults = UserDefaults.standard
    var dataArray = [HomeSlider]()
    var categoryArray = [CatIcon]()
    var featuredArray = [HomeAdd]()
    var latestAdsArray = [HomeAdd]()
    var blogObj : HomeLatestBlog?
    var catLocationsArray = [CatLocation]()
    var nearByAddsArray = [HomeAdd]()
    var searchSectionArray = [HomeSearchSection]()
    
    var isAdPositionSort = false
    var isShowLatest = false
    var isShowBlog = false
    var isShowNearby = false
    var isShowFeature = false
    var isShowLocationButton = false
    var isShowCategoryButton = false
    
    var featurePosition = ""
    var animalSectionTitle = ""
    var isNavSearchBarShowing = false
    let searchBarNavigation = UISearchBar()
    var backgroundView = UIView()
    var addPosition = ["search_Cell"]
    var barButtonItems = [UIBarButtonItem]()
    
    
    var viewAllText = ""
    var catLocationTitle = ""
    var nearByTitle = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var searchDistance:CGFloat = 0
    //var homeTitle = ""
    var numberOfColumns:CGFloat = 0
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.googleAnalytics(controllerName: "Home Controller")
        self.adForest_sendFCMToken()
        self.subscribeToTopicMessage()
        self.showLoader()
        self.adForest_homeData()
        self.addLeftBarButtonWithImage(UIImage(named: "menu")!)
        self.navigationButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if defaults.bool(forKey: "isGuest") || defaults.bool(forKey: "isLogin") == false {
            self.oltAddPost.isHidden = true
        }
    }
    
    //MARK:- Topic Message
    func subscribeToTopicMessage() {
        if defaults.bool(forKey: "isLogin") {
            Messaging.messaging().shouldEstablishDirectChannel = true
            Messaging.messaging().subscribe(toTopic: "global")
        }
    }
    
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //MARK:- go to add detail controller
    func goToAddDetail(ad_id: Int) {
        let addDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        addDetailVC.ad_id = ad_id
        self.navigationController?.pushViewController(addDetailVC, animated: true)
    }
    
    //MARK:- go to category detail
    func goToCategoryDetail(id: Int) {
        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
        categoryVC.categoryID = id
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    //MARK:- Go to Location detail
    func goToCLocationDetail(id: Int) {
        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
        categoryVC.categoryID = id
        categoryVC.isFromLocation = true
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    //MARK:- Go to blog detail
    func blogPostID(ID: Int) {
        let blogDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BlogDetailController") as! BlogDetailController
        blogDetailVC.post_id = ID
        self.navigationController?.pushViewController(blogDetailVC, animated: true)
    }
    
    //MARK:- Near by search Delaget method
    
    func nearbySearchParams(lat: Double, long: Double, searchDistance: CGFloat, isSearch: Bool) {
        self.latitude = lat
        self.longitude = long
        self.searchDistance = searchDistance
        if isSearch {
            let param: [String: Any] = ["nearby_latitude": lat, "nearby_longitude": long, "nearby_distance": searchDistance]
            print(param)
            self.adForest_nearBySearch(param: param as NSDictionary)
        } else {
            let param: [String: Any] = ["nearby_latitude": 0.0, "nearby_longitude": 0.0, "nearby_distance": searchDistance]
            print(param)
            self.adForest_nearBySearch(param: param as NSDictionary)
        }
    }
    
    
    func navigationButtons() {
        //Location Search
        let locationButton = UIButton(type: .custom)
        if #available(iOS 11, *) {
            locationButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
            locationButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        else {
            locationButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        }
        let image = UIImage(named: "location")?.withRenderingMode(.alwaysTemplate)
        locationButton.setBackgroundImage(image, for: .normal)
        locationButton.tintColor = UIColor.white
        locationButton.addTarget(self, action: #selector(onClicklocationButton), for: .touchUpInside)
        let barButtonLocation = UIBarButtonItem(customView: locationButton)
        if defaults.bool(forKey: "showNearBy") {
            self.barButtonItems.append(barButtonLocation)
        }
        //Search Button
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        if #available(iOS 11, *) {
            searchBarNavigation.widthAnchor.constraint(equalToConstant: 30).isActive = true
            searchBarNavigation.heightAnchor.constraint(equalToConstant: 30).isActive = true
        } else {
            searchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        searchButton.addTarget(self, action: #selector(actionSearch), for: .touchUpInside)
        let searchItem = UIBarButtonItem(customView: searchButton)
        if defaults.bool(forKey: "showNearBy") {
            barButtonItems.append(searchItem)
        }
        self.barButtonItems.append(searchItem)
        self.navigationItem.rightBarButtonItems = barButtonItems
    }
    
    @objc func onClicklocationButton() {
        let locationVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearch") as! LocationSearch
        locationVC.delegate = self
        view.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.view.transform = .identity
        }) { (success) in
            self.navigationController?.pushViewController(locationVC, animated: true)
        }
    }
    
    //MARK:- AdMob Delegate Methods
    
    func swiftyAdDidOpen(_ swiftyAd: SwiftyAd) {
        print("Open")
    }
    
    func swiftyAdDidClose(_ swiftyAd: SwiftyAd) {
        print("Close")
    }
    
    func swiftyAd(_ swiftyAd: SwiftyAd, didRewardUserWithAmount rewardAmount: Int) {
        print(rewardAmount)
    }

    //MARK:- Search Controller
    @objc func actionSearch(_ sender: Any) {
        if isNavSearchBarShowing {
            self.searchBarNavigation.text = ""
            self.backgroundView.removeFromSuperview()
            self.addTitleView()
        } else {
            self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.backgroundView.isOpaque = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tap.delegate = self
            self.backgroundView.addGestureRecognizer(tap)
            self.backgroundView.isUserInteractionEnabled = true
            self.view.addSubview(self.backgroundView)
            self.adNavSearchBar()
        }
    }
    
    @objc func handleTap(_ gestureRocognizer: UITapGestureRecognizer) {
        self.actionSearch("")
    }
    
    func adNavSearchBar() {
        searchBarNavigation.placeholder = "Search Ads"
        searchBarNavigation.barStyle = .default
        searchBarNavigation.isTranslucent = false
        searchBarNavigation.barTintColor = UIColor.groupTableViewBackground
        searchBarNavigation.backgroundImage = UIImage()
        searchBarNavigation.sizeToFit()
        searchBarNavigation.delegate = self
        self.isNavSearchBarShowing = true
        searchBarNavigation.isHidden = false
        navigationItem.titleView = searchBarNavigation
        searchBarNavigation.becomeFirstResponder()
    }
    
    func addTitleView() {
        self.isNavSearchBarShowing = false
        self.searchBarNavigation.isHidden = true
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK:- Search Bar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.view.endEditing(true)
        guard let searchText = searchBar.text else {return}
        if searchText == "" {
            
        } else {
            let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
            categoryVC.searchText = searchText
            categoryVC.isFromTextSearch = true
            self.navigationController?.pushViewController(categoryVC, animated: true)
        }
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isAdPositionSort {
            return addPosition.count
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0
        if isAdPositionSort {
            let position = addPosition[section]
            if position == "sliders" {
                value = dataArray.count
            } else {
                value = 1
            }
        }
            // Else Condition of Second Type
        else {
            if featurePosition == "1" {
                if section == 0 {
                    value = 1
                } else if section == 1 {
                    if isShowFeature {
                        value = 1
                    } else {
                        value = 0
                    }
                } else if section == 2 {
                    value = 1
                } else if section == 3 {
                    value = dataArray.count
                }
            } else if featurePosition == "2" {
                if section == 0 {
                    value = 1
                } else if section == 1 {
                    value = 1
                } else if section == 2 {
                    if isShowFeature {
                        value = 1
                    } else {
                        value = 0
                    }
                } else if section == 3 {
                    value = dataArray.count
                }
            } else if featurePosition == "3" {
                if section == 0 {
                    value = 1
                } else if section == 1 {
                    value = 1
                } else if section == 2 {
                    value = dataArray.count
                } else if section == 3 {
                    if isShowFeature {
                        value = 1
                    } else {
                        value = 0
                    }
                }
            }
        }
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if isAdPositionSort {
            let position = addPosition[section]
            switch position {
            case "search_Cell":
                let cell: SearchSectionCell = tableView.dequeueReusableCell(withIdentifier: "SearchSectionCell", for: indexPath) as! SearchSectionCell
                let objData = searchSectionArray[indexPath.row]
                if objData.isShow {
                    if let imgUrl = URL(string: objData.image) {
                        cell.imgPicture.sd_setShowActivityIndicatorView(true)
                        cell.imgPicture.sd_setIndicatorStyle(.gray)
                        cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                    }
                    if let title = objData.mainTitle {
                        cell.lblTitle.text = title
                    }
                    if let subTitle = objData.subTitle {
                        cell.lblSubTitle.text = subTitle
                    }
                    if let placeHolder = objData.placeholder {
                        cell.txtSearch.placeholder = placeHolder
                    }
                }
                return cell
            case "blogNews":
                if self.isShowBlog {
                    let cell: HomeBlogCell = tableView.dequeueReusableCell(withIdentifier: "HomeBlogCell", for: indexPath) as! HomeBlogCell
                    let objData = blogObj
                    if let name = objData?.text {
                        cell.lblName.text = name
                    }
                    cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    cell.btnViewAll = { () in
                        let blogVC = self.storyboard?.instantiateViewController(withIdentifier: "BlogController") as! BlogController
                        blogVC.isFromHomeBlog = true
                        self.navigationController?.pushViewController(blogVC, animated: true)
                    }
                    cell.dataArray = (objData?.blogs)!
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                }
            case "cat_icons":
                let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                let data = AddsHandler.sharedInstance.objHomeData
                
                if self.isShowCategoryButton {
                    cell.oltViewAll.isHidden = false
                    if let viewAllText = data?.catIconsColumnBtn.text {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAll = { () in
                        let categoryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryDetailController") as! CategoryDetailController
                        self.navigationController?.pushViewController(categoryDetailVC, animated: true)
                    }
                } else {
                    cell.oltViewAll.isHidden = true
                }
                cell.numberOfColums = self.numberOfColumns
                cell.categoryArray  = self.categoryArray
                cell.delegate = self
                cell.collectionView.reloadData()
                return cell
            case "featured_ads":
                if isShowFeature {
                    let cell: HomeFeatureAddCell = tableView.dequeueReusableCell(withIdentifier: "HomeFeatureAddCell", for: indexPath) as! HomeFeatureAddCell
                    let data = AddsHandler.sharedInstance.objHomeData
                    if let sectionTitle = data?.featuredAds.text {
                        cell.lblTitle.text = sectionTitle
                    }
                    cell.dataArray = featuredArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                }
            case "latest_ads":
                if isShowLatest {
                    let cell: LatestAddsCell  = tableView.dequeueReusableCell(withIdentifier: "LatestAddsCell", for: indexPath) as! LatestAddsCell
                    let data = AddsHandler.sharedInstance.objHomeData
                    let objData = AddsHandler.sharedInstance.objLatestAds
                    
                    if let sectionTitle = objData?.text {
                        cell.lblTitle.text = sectionTitle
                    }
                    if let viewAllText = data?.viewAll {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAll = { () in
                        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                        self.navigationController?.pushViewController(categoryVC, animated: true)
                    }
                    cell.delegate = self
                    cell.dataArray = self.latestAdsArray
                    cell.collectionView.reloadData()
                    return cell
                }
            case "cat_locations":
                let cell: HomeNearAdsCell = tableView.dequeueReusableCell(withIdentifier: "HomeNearAdsCell", for: indexPath) as! HomeNearAdsCell
                let data = AddsHandler.sharedInstance.objHomeData
                
                if self.isShowLocationButton {
                    cell.oltViewAll.isHidden = false
                    if let viewAllText = data?.catLocationsBtn.text {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAction = { () in
                        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationDetailController") as! LocationDetailController
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                } else {
                    cell.oltViewAll.isHidden = true
                }
                cell.lblTitle.text = catLocationTitle
                cell.dataArray = catLocationsArray
                cell.delegate = self
                cell.collectionView.reloadData()
                return cell
            case "sliders":
                let cell: AddsTableCell  = tableView.dequeueReusableCell(withIdentifier: "AddsTableCell", for: indexPath) as! AddsTableCell
                let objData = dataArray[indexPath.row]
                let data = AddsHandler.sharedInstance.objHomeData
                
                if let sectionTitle = objData.name {
                    cell.lblSectionTitle.text = sectionTitle
                }
                if let viewAllText = data?.viewAll {
                    cell.oltViewAll.setTitle(viewAllText, for: .normal)
                }
                
                cell.btnViewAll = { () in
                    let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                    categoryVC.categoryID = objData.catId
                    self.navigationController?.pushViewController(categoryVC, animated: true)
                }
                cell.dataArray = objData.data
                cell.delegate = self
                cell.reloadData()
                return cell
            case "nearby":
                if self.isShowNearby {
                    let cell: AddsTableCell = tableView.dequeueReusableCell(withIdentifier: "AddsTableCell", for: indexPath) as! AddsTableCell
                    cell.lblSectionTitle.text = self.nearByTitle
                    cell.dataArray = self.nearByAddsArray
                    cell.collectionView.reloadData()
                    return cell
                }
            default:
                break
            }
        }
        else {
            if featurePosition == "1" {
                if section == 0 {
                    let cell: SearchSectionCell = tableView.dequeueReusableCell(withIdentifier: "SearchSectionCell", for: indexPath) as! SearchSectionCell
                    let objData = searchSectionArray[indexPath.row]
                    if objData.isShow {
                        if let imgUrl = URL(string: objData.image) {
                            cell.imgPicture.sd_setShowActivityIndicatorView(true)
                            cell.imgPicture.sd_setIndicatorStyle(.gray)
                            cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                        }
                        if let title = objData.mainTitle {
                            cell.lblTitle.text = title
                        }
                        if let subTitle = objData.subTitle {
                            cell.lblSubTitle.text = subTitle
                        }
                        if let placeHolder = objData.placeholder {
                            cell.txtSearch.placeholder = placeHolder
                        }
                    }
                    return cell
                }
                else if section == 1 {
                    if isShowFeature {
                        let cell: HomeFeatureAddCell = tableView.dequeueReusableCell(withIdentifier: "HomeFeatureAddCell", for: indexPath) as! HomeFeatureAddCell
                        let data = AddsHandler.sharedInstance.objHomeData
                        if let sectionTitle = data?.featuredAds.text {
                            cell.lblTitle.text = sectionTitle
                        }
                        cell.dataArray = featuredArray
                        cell.delegate = self
                        cell.collectionView.reloadData()
                        return cell
                    }
                }
                else if section == 2 {
                    let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                    let data = AddsHandler.sharedInstance.objHomeData
                    if let viewAllText = data?.catIconsColumnBtn.text {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAll = { () in
                        let categoryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryDetailController") as! CategoryDetailController
                        self.navigationController?.pushViewController(categoryDetailVC, animated: true)
                    }
                    cell.numberOfColums = self.numberOfColumns
                    cell.categoryArray  = self.categoryArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                }
                else if section == 3 {
                    let cell: AddsTableCell  = tableView.dequeueReusableCell(withIdentifier: "AddsTableCell", for: indexPath) as! AddsTableCell
                    let objData = dataArray[indexPath.row]
                    let data = AddsHandler.sharedInstance.objHomeData
                    
                    if let sectionTitle = objData.name {
                        cell.lblSectionTitle.text = sectionTitle
                    }
                    if let viewAllText = data?.viewAll {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAll = { () in
                        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                        categoryVC.categoryID = objData.catId
                        self.navigationController?.pushViewController(categoryVC, animated: true)
                    }
                    cell.dataArray = objData.data
                    cell.delegate = self
                    cell.reloadData()
                    return cell
                }
            }
            else if featurePosition == "2" {
                if section == 0 {
                    let cell: SearchSectionCell = tableView.dequeueReusableCell(withIdentifier: "SearchSectionCell", for: indexPath) as! SearchSectionCell
                    let objData = searchSectionArray[indexPath.row]
                    if objData.isShow {
                        if let imgUrl = URL(string: objData.image) {
                            cell.imgPicture.sd_setShowActivityIndicatorView(true)
                            cell.imgPicture.sd_setIndicatorStyle(.gray)
                            cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                        }
                        if let title = objData.mainTitle {
                            cell.lblTitle.text = title
                        }
                        if let subTitle = objData.subTitle {
                            cell.lblSubTitle.text = subTitle
                        }
                        if let placeHolder = objData.placeholder {
                            cell.txtSearch.placeholder = placeHolder
                        }
                    }
                    return cell
                }
                else  if section == 1 {
                    let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                    let data = AddsHandler.sharedInstance.objHomeData
                    if let viewAllText = data?.catIconsColumnBtn.text {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAll = { () in
                        let categoryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryDetailController") as! CategoryDetailController
                        self.navigationController?.pushViewController(categoryDetailVC, animated: true)
                    }
                    cell.numberOfColums = self.numberOfColumns
                    cell.categoryArray  = self.categoryArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                }
                else if section == 2 {
                    if isShowFeature {
                        let cell: HomeFeatureAddCell = tableView.dequeueReusableCell(withIdentifier: "HomeFeatureAddCell", for: indexPath) as! HomeFeatureAddCell
                        let data = AddsHandler.sharedInstance.objHomeData
                        if let sectionTitle = data?.featuredAds.text {
                            cell.lblTitle.text = sectionTitle
                        }
                        cell.dataArray = featuredArray
                        cell.delegate = self
                        cell.collectionView.reloadData()
                        return cell
                    }
                }
                else if section == 3 {
                    let cell: AddsTableCell  = tableView.dequeueReusableCell(withIdentifier: "AddsTableCell", for: indexPath) as! AddsTableCell
                    let objData = dataArray[indexPath.row]
                    let data = AddsHandler.sharedInstance.objHomeData
                    
                    if let sectionTitle = objData.name {
                        cell.lblSectionTitle.text = sectionTitle
                    }
                    if let viewAllText = data?.viewAll {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    
                    cell.btnViewAll = { () in
                        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                        categoryVC.categoryID = objData.catId
                        self.navigationController?.pushViewController(categoryVC, animated: true)
                    }
                    cell.dataArray = objData.data
                    cell.delegate = self
                    cell.reloadData()
                    return cell
                }
            }
                
            else if featurePosition == "3" {
                if section == 0 {
                    let cell: SearchSectionCell = tableView.dequeueReusableCell(withIdentifier: "SearchSectionCell", for: indexPath) as! SearchSectionCell
                    let objData = searchSectionArray[indexPath.row]
                    if objData.isShow {
                        if let imgUrl = URL(string: objData.image) {
                            cell.imgPicture.sd_setShowActivityIndicatorView(true)
                            cell.imgPicture.sd_setIndicatorStyle(.gray)
                            cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                        }
                        if let title = objData.mainTitle {
                            cell.lblTitle.text = title
                        }
                        if let subTitle = objData.subTitle {
                            cell.lblSubTitle.text = subTitle
                        }
                        if let placeHolder = objData.placeholder {
                            cell.txtSearch.placeholder = placeHolder
                        }
                    }
                    return cell
                } else if section == 1 {
                    let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                    let data = AddsHandler.sharedInstance.objHomeData
                    if let viewAllText = data?.catIconsColumnBtn.text {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    cell.btnViewAll = { () in
                        let categoryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryDetailController") as! CategoryDetailController
                        self.navigationController?.pushViewController(categoryDetailVC, animated: true)
                    }
                    cell.numberOfColums = self.numberOfColumns
                    cell.categoryArray  = self.categoryArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                } else if section == 2 {
                    let cell: AddsTableCell  = tableView.dequeueReusableCell(withIdentifier: "AddsTableCell", for: indexPath) as! AddsTableCell
                    let objData = dataArray[indexPath.row]
                    let data = AddsHandler.sharedInstance.objHomeData
                    
                    if let sectionTitle = objData.name {
                        cell.lblSectionTitle.text = sectionTitle
                    }
                    if let viewAllText = data?.viewAll {
                        cell.oltViewAll.setTitle(viewAllText, for: .normal)
                    }
                    
                    cell.btnViewAll = { () in
                        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                        categoryVC.categoryID = objData.catId
                        self.navigationController?.pushViewController(categoryVC, animated: true)
                    }
                    cell.dataArray = objData.data
                    cell.delegate = self
                    cell.reloadData()
                    return cell
                } else if section == 3 {
                    if isShowFeature {
                        let cell: HomeFeatureAddCell = tableView.dequeueReusableCell(withIdentifier: "HomeFeatureAddCell", for: indexPath) as! HomeFeatureAddCell
                        let data = AddsHandler.sharedInstance.objHomeData
                        if let sectionTitle = data?.featuredAds.text {
                            cell.lblTitle.text = sectionTitle
                        }
                        cell.dataArray = featuredArray
                        cell.delegate = self
                        cell.collectionView.reloadData()
                        return cell
                    }
                }
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        var totalHeight : CGFloat = 0
        var height: CGFloat = 0
        if isAdPositionSort {
            let position = addPosition[section]
            if position == "search_Cell" {
                let objData = searchSectionArray[indexPath.row]
                if objData.isShow {
                    height = 250
                } else {
                    height = 0
                }
            }
            else if position == "cat_icons" {
                if Constants.isiPadDevice {
                    height = 230
                } else {
                    if numberOfColumns == 3 {
                        let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                        let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                        let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                        let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                        if Constants.isiPhone5 {
                            totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 80)
                        } else {
                            totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                        }
                        height =  totalHeight
                    } else if numberOfColumns == 4 {
                        let itemHeight = CollectionViewForuCell.getItemWidth(boundWidth: tableView.bounds.size.width)
                        let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewForuCell.column)
                        let totalTopBottomOffSet = CollectionViewForuCell.offset + CollectionViewForuCell.offset
                        let totalSpacing = CGFloat(totalRow - 1) * CollectionViewForuCell.minLineSpacing
                        if Constants.isiPhone5 {
                            totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 170)
                        } else {
                            totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 140)
                        }
                        height =  totalHeight
                    }
                }
            }
            else if position == "cat_locations"  {
                if categoryArray.isEmpty {
                    height = 0
                } else {
                    if self.isShowLocationButton {
                        height = 250
                    } else {
                        height = 225
                    }
                }
            } else if position == "nearby" {
                if isShowNearby {
                    height = 270
                } else {
                    height = 0
                }
            } else if position == "sliders" {
                if dataArray.isEmpty {
                    height = 0
                } else {
                    height = 270
                }
            } else if position == "blogNews"{
                if self.isShowBlog {
                    height = 270
                } else {
                    height = 0
                }
            } else if position == "featured_ads" {
                if self.isShowFeature {
                    if featuredArray.isEmpty {
                        height = 0
                    } else {
                        height = 270
                    }
                } else {
                    height = 0
                }
            } else if position ==  "latest_ads" {
                if self.isShowLatest {
                    height = 270
                } else {
                    height = 0
                }
            } else {
                height = 0
            }
        } else {
            if featurePosition == "1" {
                if section == 0 {
                    let objData = searchSectionArray[indexPath.row]
                    if objData.isShow {
                        height = 250
                    } else {
                        height = 0
                    }
                }
                else if section == 1 {
                    height = 270
                }
                else if section == 2 {
                    if Constants.isiPadDevice {
                        height = 220
                    }
                    else {
                        if numberOfColumns == 3 {
                            let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                            let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                            let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                            let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                            if Constants.isiPhone5 {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 80)
                            } else {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                            }
                            height =  totalHeight
                        } else if numberOfColumns == 4 {
                            let itemHeight = CollectionViewForuCell.getItemWidth(boundWidth: tableView.bounds.size.width)
                            let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewForuCell.column)
                            let totalTopBottomOffSet = CollectionViewForuCell.offset + CollectionViewForuCell.offset
                            let totalSpacing = CGFloat(totalRow - 1) * CollectionViewForuCell.minLineSpacing
                            if Constants.isiPhone5 {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 170)
                            } else {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 140)
                            }
                            height =  totalHeight
                        }
                    }
                }
                else if section == 3 {
                    height = 270
                }
            }
            else if featurePosition == "2" {
                if section == 0 {
                    let objData = searchSectionArray[indexPath.row]
                    if objData.isShow {
                        height = 250
                    } else {
                        height = 0
                    }
                }
                else if section == 1 {
                    if Constants.isiPadDevice {
                        height = 220
                    } else {
                        if numberOfColumns == 3 {
                            let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                            let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                            let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                            let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                            if Constants.isiPhone5 {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 80)
                            } else {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                            }
                            height =  totalHeight
                        } else if numberOfColumns == 4 {
                            let itemHeight = CollectionViewForuCell.getItemWidth(boundWidth: tableView.bounds.size.width)
                            let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewForuCell.column)
                            let totalTopBottomOffSet = CollectionViewForuCell.offset + CollectionViewForuCell.offset
                            let totalSpacing = CGFloat(totalRow - 1) * CollectionViewForuCell.minLineSpacing
                            if Constants.isiPhone5 {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 170)
                            } else {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 140)
                            }
                            height =  totalHeight
                        }
                    }
                }
                else if section ==  2 {
                    height = 270
                }
                else if section == 3 {
                    height = 270
                }
            }
            else if featurePosition == "3" {
                if section == 0 {
                    let objData = searchSectionArray[indexPath.row]
                    if objData.isShow {
                        height = 250
                    } else {
                        height = 0
                    }
                } else if section == 1 {
                    if Constants.isiPadDevice {
                        height = 220
                    }
                    else {
                        if numberOfColumns == 3 {
                            let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                            let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                            let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                            let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                            if Constants.isiPhone5 {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 80)
                            } else {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                            }
                            height =  totalHeight
                        } else if numberOfColumns == 4 {
                            let itemHeight = CollectionViewForuCell.getItemWidth(boundWidth: tableView.bounds.size.width)
                            let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewForuCell.column)
                            let totalTopBottomOffSet = CollectionViewForuCell.offset + CollectionViewForuCell.offset
                            let totalSpacing = CGFloat(totalRow - 1) * CollectionViewForuCell.minLineSpacing
                            if Constants.isiPhone5 {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 170)
                            } else {
                                totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 140)
                            }
                            height =  totalHeight
                        }
                    }
                }
                else if section == 2 {
                    height = 270
                }
                else if section == 3 {
                    height = 270
                }
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    //MARK:- IBActions
    @IBAction func actionAddPost(_ sender: UIButton) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    
    //MARK:- API Call
    
    //get home data
    func adForest_homeData() {
        AddsHandler.homeData(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                if let column = successResponse.data.catIconsColumn {
                    let columns = Int(column)
                    self.numberOfColumns = CGFloat(columns!)
                }
                //To Show Title After Search Bar Hidden
                self.viewAllText = successResponse.data.viewAll
    
                //Get value of show/hide buttons of location and categories
                if successResponse.data.catIconsColumnBtn != nil {
                    self.isShowCategoryButton = successResponse.data.catIconsColumnBtn.isShow
                }
                if successResponse.data.catLocationsBtn != nil {
                    self.isShowLocationButton = successResponse.data.catLocationsBtn.isShow
                }
                
                if let feature = successResponse.data.isShowFeatured {
                    self.isShowFeature = feature
                }
                if let feature = successResponse.data.featuredPosition {
                    self.featurePosition = feature
                }
                self.categoryArray = successResponse.data.catIcons
                self.dataArray = successResponse.data.sliders
                
                //Check Feature Ads is on or off and set add Position Sorter
                if self.isShowFeature {
                    self.featuredArray = successResponse.data.featuredAds.ads
                }
                if let isSort = successResponse.data.adsPositionSorter {
                    self.isAdPositionSort = isSort
                }
                if self.isAdPositionSort {
                    self.addPosition += successResponse.data.adsPosition
                    if let latest = successResponse.data.isShowLatest {
                        self.isShowLatest = latest
                    }
                    if self.isShowLatest {
                        self.latestAdsArray = successResponse.data.latestAds.ads
                    }
                    
                    if let showBlog = successResponse.data.isShowBlog {
                        self.isShowBlog = showBlog
                    }
                    if self.isShowBlog {
                        self.blogObj = successResponse.data.latestBlog
                    }
                    
                    if let showNearAds = successResponse.data.isShowNearby {
                        self.isShowNearby = showNearAds
                    }
                    if self.isShowNearby {
                        self.nearByTitle = successResponse.data.nearbyAds.text
                        if successResponse.data.nearbyAds.ads.isEmpty == false {
                            self.nearByAddsArray = successResponse.data.nearbyAds.ads
                        }
                    }
                    if successResponse.data.catLocations.isEmpty == false {
                        self.catLocationsArray = successResponse.data.catLocations
                        if let locationTitle = successResponse.data.catLocationsTitle {
                            self.catLocationTitle = locationTitle
                        }
                    }
                }
                AddsHandler.sharedInstance.objHomeData = successResponse.data
                AddsHandler.sharedInstance.objLatestAds = successResponse.data.latestAds
                
                // Set Up AdMob Banner & Intersitial ID's
                    UserHandler.sharedInstance.objAdMob = successResponse.settings.ads
                    var isShowAd = false
                    if let adShow = successResponse.settings.ads.show {
                        isShowAd = adShow
                    }
                    if isShowAd {
                        SwiftyAd.shared.delegate = self
                        var isShowBanner = false
                        var isShowInterstital = false
                        
                        if let banner = successResponse.settings.ads.isShowBanner {
                            isShowBanner = banner
                        }
                        if let intersitial = successResponse.settings.ads.isShowInitial {
                            isShowInterstital = intersitial
                        }
                        if isShowBanner {
                            SwiftyAd.shared.setup(withBannerID: successResponse.settings.ads.bannerId, interstitialID: "", rewardedVideoID: "")
                            self.tableView.translatesAutoresizingMaskIntoConstraints = false
                            if successResponse.settings.ads.position == "top" {
                                self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40).isActive = true
                                SwiftyAd.shared.showBanner(from: self, at: .top)
                            } else {
                                self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 30).isActive = true
                                SwiftyAd.shared.showBanner(from: self, at: .bottom)
                            }
                        }
                        if isShowInterstital {
                            SwiftyAd.shared.setup(withBannerID: "", interstitialID: successResponse.settings.ads.interstitalId, rewardedVideoID: "")
                            SwiftyAd.shared.showInterstitial(from: self, withInterval: 1)
                        }
                    }
                // Here I set the Google Analytics Key
                var isShowAnalytic = false
                if let isShow = successResponse.settings.analytics.show {
                    isShowAnalytic = isShow
                }
                if isShowAnalytic {
                    if let analyticKey = successResponse.settings.analytics.id {
                        guard let gai = GAI.sharedInstance() else {
                            assert(false, "Google Analytics not configured correctly")
                            return
                        }
                        gai.tracker(withTrackingId: analyticKey)
                        gai.trackUncaughtExceptions = true
                    }
                }
                //Search Section Data
                self.searchSectionArray = [successResponse.data.searchSection]
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
    
    //MARK:- Send fcm token to server
    func adForest_sendFCMToken() {
        var fcmToken = ""
        if let token = defaults.value(forKey: "fcmToken") as? String {
            fcmToken = token
        } else {
            fcmToken = appDelegate.deviceFcmToken
        }
        let param: [String: Any] = ["firebase_id": fcmToken]
        print(param)
        AddsHandler.sendFirebaseToken(parameter: param as NSDictionary, success: { (successResponse) in
            self.stopAnimating()
            print(successResponse)
        }) { (error) in
            self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
    
    //MARK:- Near By Search
    func adForest_nearBySearch(param: NSDictionary) {
        self.showLoader()
        AddsHandler.nearbyAddsSearch(params: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                categoryVC.latitude = self.latitude
                categoryVC.longitude = self.longitude
                categoryVC.nearByDistance = self.searchDistance
                categoryVC.isFromNearBySearch = true
                self.navigationController?.pushViewController(categoryVC, animated: true)
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
