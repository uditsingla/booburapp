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
import GoogleMobileAds
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseCore
import FirebaseInstanceID

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, AddDetailDelegate, CategoryDetailDelegate, UISearchBarDelegate , GADBannerViewDelegate, MessagingDelegate , UNUserNotificationCenterDelegate, NearBySearchDelegate, BlogDetailDelegate , LocationCategoryDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorStyle = .none
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
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var topBannerAdd: GADBannerView!
    
    //MARK:- Properties
    
    var defaults = UserDefaults.standard
    var dataArray = [HomeSlider]()
    var categoryArray = [CatIcon]()
    var featuredArray = [HomeAdd]()
    var latestAdsArray = [HomeAdd]()
    var blogObj : HomeLatestBlog?
    var catLocationsArray = [CatLocation]()
    var nearByAddsArray = [String]()
    
    var isShowFeature = false
    var featurePosition = ""
    var animalSectionTitle = ""
    var isNavSearchBarShowing = false
    let searchBarNavigation = UISearchBar()
    var backgroundView = UIView()
    var addPosition = [String]()
    var isAdPositionSort = false
    var isShowLatest = false
    var isShowBlog = false
    
    var viewAllText = ""
    var catLocationTitle = ""
    
    var latitude: Double = 0
    var longitude: Double = 0
    var searchDistance: CGFloat = 0
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shareButton()
      //  self.nearByLocationButton()
        self.adForest_sendFCMToken()
        self.subscribeToTopicMessage()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if defaults.bool(forKey: "isRtl") {
            self.addRightBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
        else {
            self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))
        }
        self.adForest_homeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Home Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    
    //MARK: - Custom
    
    func subscribeToTopicMessage() {
        if defaults.bool(forKey: "isLogin") {
            Messaging.messaging().shouldEstablishDirectChannel = true
            Messaging.messaging().subscribe(toTopic: "global")
        }
    }
    
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func showGoogleAdd(unitID: String, adPosition: GADBannerView) {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adPosition.rootViewController = self
        //set up add
        adPosition.adUnitID = unitID
        adPosition.delegate = self
        adPosition.load(request)
    }
    
    //go to add detail controller
    func goToAddDetail(ad_id: Int) {
        let addDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        addDetailVC.ad_id = ad_id
        self.navigationController?.pushViewController(addDetailVC, animated: true)
    }
    
    // go to category detail
    func goToCategoryDetail(id: Int) {
        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
        categoryVC.categoryID = id
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
  // Go to Location detail
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
    
    // Near by search Delaget method
    func nearbySearchParams(lat: Double, long: Double, searchDistance: CGFloat) {
        let param: [String: Any] = ["nearby_latitude": lat, "nearby_longitude": long, "nearby_distance": searchDistance]
        print(param)
        self.latitude = lat
        self.longitude = long
        self.searchDistance = searchDistance
        self.adForest_nearBySearch(param: param as NSDictionary)
    }
    
    func nearByLocationButton() {
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
        
        let shareButton = UIButton(type: .custom)
        if #available(iOS 11, *) {
            shareButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
            shareButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        else {
            shareButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        }
        shareButton.setBackgroundImage(#imageLiteral(resourceName: "appShare"), for: .normal)
        shareButton.addTarget(self, action: #selector(onClickShareButton), for: .touchUpInside)
        let barButtonShare = UIBarButtonItem(customView: shareButton)
        self.navigationItem.rightBarButtonItems = [barButtonShare, barButtonLocation]
    }
    
    @objc func onClicklocationButton() {
        let locationVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearch") as! LocationSearch
        locationVC.modalPresentationStyle = .overCurrentContext
        locationVC.modalTransitionStyle = .flipHorizontal
        locationVC.delegate = self
        self.presentVC(locationVC)
    }
    
    
    func searchBarButton() {
        let imageSearch = UIImage (named: "search")
        let searchTintedImage = imageSearch?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        let searchButton = UIButton(type: .custom)
        searchButton.setImage(searchTintedImage, for: .normal)
        searchButton.addTarget(self, action: #selector(onClickSearchButton), for: .touchUpInside)
        if #available(iOS 11, *) {
            searchButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            searchButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        else {
            searchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        let barButton = UIBarButtonItem(customView: searchButton)
        self.navigationItem.rightBarButtonItem = barButton
        
    }
    
    @objc func onClickSearchButton() {
        if isNavSearchBarShowing {
            self.searchBarNavigation.text = ""
            self.backgroundView.removeFromSuperview()
        }
    }
    
    func addTitleView() {
        self.isNavSearchBarShowing = false
        self.searchBarNavigation.isHidden = true
    }
    
    func adForest_populateData() {
        if  AddsHandler.sharedInstance.objHomeAdd != nil {
            let dataToShow = AddsHandler.sharedInstance.objHomeAdd
            
            if let addShow = dataToShow?.show {
                if let isShowBanner = dataToShow?.isShowBanner {
                    if let bannerID = dataToShow?.bannerId {
                        if dataToShow?.position == "top" {
                            self.tableView.translatesAutoresizingMaskIntoConstraints = false
                            self.tableView.topAnchor.constraint(equalTo: self.topBannerAdd.bottomAnchor, constant: 0).isActive = true
                           // self.showGoogleAdd(unitID: bannerID, adPosition: topBannerAdd)
                        }
                        else if dataToShow?.position == "bottom" {
                            self.tableView.translatesAutoresizingMaskIntoConstraints = false
                            self.tableView.bottomAnchor.constraint(equalTo: self.bannerView.topAnchor, constant: 0).isActive = true
                          //  self.showGoogleAdd(unitID: bannerID, adPosition: bannerView)
                        }
                    }
                }
            }
        }
    }
    
    
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isAdPositionSort {
            return addPosition.count
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0
        if isAdPositionSort {
            let position = addPosition[section]
            if position == "sliders" {
                value = dataArray.count
            }
            else {
                value = 1
            }
        }
            
            // Else Condition of Second Type
        else {
            
            if featurePosition == "1" {
                if section == 0 {
                    if isShowFeature {
                         value = 1
                    }
                    else {
                        value = 0
                    }
                }
                else if section == 1 {
                    value = 1
                }
                else if section == 2 {
                    value = dataArray.count
                }
            }
            
            else if featurePosition == "2" {
                if section == 0 {
                    value = 1
                }
                else if section == 1 {
                    if isShowFeature {
                         value = 1
                    }
                    else {
                        value = 0
                    }
                }
                else if section == 2 {
                    value = dataArray.count
                }
            }
            
            else if featurePosition == "3" {
                if section == 0 {
                    value = 1
                }
                else if section == 1 {
                    value = dataArray.count
                }
                else if section == 2 {
                    if isShowFeature {
                         value = 1
                    }
                    else {
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
            if position == "blogNews" {
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
            }
            else if position == "cat_icons" {
                let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                cell.categoryArray  = self.categoryArray
                cell.delegate = self
                cell.collectionView.reloadData()
                return cell
            }
            else if position == "featured_ads" {
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
            else if position == "latest_ads" {
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
            }
            else if position == "cat_locations" {
                let cell: HomeNearAdsCell = tableView.dequeueReusableCell(withIdentifier: "HomeNearAdsCell", for: indexPath) as! HomeNearAdsCell
                
                cell.lblTitle.text = catLocationTitle
                cell.dataArray = catLocationsArray
                cell.delegate = self
                cell.collectionView.reloadData()
                return cell
            }
            else if position == "sliders" {
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
//            else if position == "nearby" {
//
//            }
        }
        else {
            if featurePosition == "1" {
                if section == 0 {
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
                else if section == 1 {
                    let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                    cell.categoryArray  = self.categoryArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                }
                else if section == 2 {
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
                    let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                    cell.categoryArray  = self.categoryArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
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
                    let cell: CategoriesTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableCell", for: indexPath) as! CategoriesTableCell
                    cell.categoryArray  = self.categoryArray
                    cell.delegate = self
                    cell.collectionView.reloadData()
                    return cell
                }
                else if section == 1 {
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
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        var height: CGFloat = 0
        
        if isAdPositionSort {
            let position = addPosition[section]
            
            if position == "cat_icons" {
                if Constants.isiPadDevice {
                    height = 0
                }
                else {
                    let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                    let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                    let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                    let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                    let totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                    height =  totalHeight
                }
            }
            else if position == "cat_locations"  {
                if categoryArray.isEmpty {
                    height = 0
                }
                else {
                    height = 200
                }
            }
                
            else if position == "nearby" {
                if nearByAddsArray.isEmpty {
                    height = 0
                }
                else {
                    height = 270
                }
            }
            else if position == "featured_ads" {
                if featuredArray.isEmpty {
                    height = 0
                }
                else {
                    height = 270
                }
            }
            else if position == "blogNews"{
                if self.isShowBlog {
                    height = 270
                }
                else {
                    height = 0
                }
            }
            else if position == "featured_ads" {
                if self.isShowFeature {
                        height = 270
                }
                else {
                    height = 0
                }
            }
            else if position ==  "latest_ads" {
                if self.isShowLatest {
                    height = 270
                }
                else {
                    height = 0
                }
            }
            else {
                height = 270
            }
        }
        
        else {
            if featurePosition == "1"{
                if section == 0 {
                    height = 270
                }
                else if section == 1 {
                    if Constants.isiPadDevice {
                        height = 0
                    }
                    else {
                        let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                        let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                        let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                        let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                        let totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                        height =  totalHeight
                    }
                }
                else if section == 2 {
                    height = 270
                }
            }
            else   if featurePosition == "2" {
                if section == 0 {
                    if Constants.isiPadDevice {
                        height = 0
                    }
                    else {
                        let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                        let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                        let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                        let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                        let totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                        height =  totalHeight
                    }
                }
                else if section ==  1 {
                    height = 270
                }
                else if section == 2 {
                    height = 270
                }
            }
            else if featurePosition == "3" {
                if section == 0 {
                    if Constants.isiPadDevice {
                        height = 0
                    }
                    else {
                        let itemHeight = CollectionViewSettings.getItemWidth(boundWidth: tableView.bounds.size.width)
                        let totalRow = ceil(CGFloat(categoryArray.count) / CollectionViewSettings.column)
                        let totalTopBottomOffSet = CollectionViewSettings.offset + CollectionViewSettings.offset
                        let totalSpacing = CGFloat(totalRow - 1) * CollectionViewSettings.minLineSpacing
                        let totalHeight = ((itemHeight * CGFloat(totalRow)) + totalTopBottomOffSet + totalSpacing + 60)
                        height =  totalHeight
                    }
                }
                else if section == 1 {
                    height = 270
                }
                else if section == 2 {
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
    
    @IBAction func actionAddPost(_ sender: Any) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    

    //MARK:- API Call
    //get home data
    
    func adForest_homeData() {
        self.showLoader()
        AddsHandler.homeData(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                DispatchQueue.main.async {
                    self.title = successResponse.data.pageTitle
                    self.viewAllText = successResponse.data.viewAll
                    
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
                        self.addPosition = successResponse.data.adsPosition
                       // self.isShowLatest = successResponse.data.isShowLatest
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
                       
                        if successResponse.data.catLocations.isEmpty == false {
                            self.catLocationsArray = successResponse.data.catLocations
                            if let locationTitle = successResponse.data.catLocationsTitle {
                                self.catLocationTitle = locationTitle
                            }
                        }
                    }
                    AddsHandler.sharedInstance.objHomeData = successResponse.data
                    AddsHandler.sharedInstance.objLatestAds = successResponse.data.latestAds
                    AddsHandler.sharedInstance.objHomeAdd = successResponse.settings.ads
                    
                    // Here I set the Stripe Key for payment
                    if let stripeKey = successResponse.settings.appKey.stripe {
                        STPPaymentConfiguration.shared().publishableKey = stripeKey
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
                    self.adForest_populateData()
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
                
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
    
    // send fcm token to server
    
    func adForest_sendFCMToken() {
        var fcmToken = ""
        if let token = defaults.value(forKey: "fcmToken") as? String {
            fcmToken = token
        }else {
            fcmToken = appDelegate.deviceFcmToken
        }
        let param: [String: Any] = ["firebase_id": fcmToken]
        print(param)
        AddsHandler.sendFirebaseToken(parameter: param as NSDictionary, success: { (successResponse) in
            self.stopAnimating()
        }) { (error) in
            self.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }
    
    func adForest_nearBySearch(param: NSDictionary) {
        self.showLoader()
        AddsHandler.nearbyAddsSearch(params: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
                categoryVC.latitude = self.latitude
                categoryVC.longitude = self.longitude
                categoryVC.nearByDistance = self.searchDistance
                self.navigationController?.pushViewController(categoryVC, animated: true)
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
