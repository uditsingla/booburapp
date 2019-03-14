//
//  CategoryController.swift
//  AdForest
//
//  Created by apple on 4/18/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DropDown
import Firebase

class CategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, CategoryFeatureDelegate {

    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //MARK:- Properties
    var categoryID = 0
    var isFromLocation = false
    
    var dataArray = [CategoryAd]()
    var categotyAdArray = [CategoryAd]()
    
    var currentPage = 0
    var maximumPage = 0
    
    var featureAddTitle = ""
    var addcategoryTitle = ""
    
    let headerDropDownButton = UIButton(type: .custom)
   
    var arrangeDropDown = DropDown()
    lazy var dropDown : [DropDown] = {
        return [
            self.arrangeDropDown
        ]
    }()
    
    var orderArray = [String]()
    var orderName = ""
    
    var isFromAdvanceSearch = false
    var isFromNearBySearch = false
    
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var nearByDistance: CGFloat = 0.0
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        //self.showLocationButton()
        // set google analytics
        Analytics.logEvent("Home_Screen", parameters: nil)
        
        self.title = "Search Results"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Category Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        if isFromAdvanceSearch {
            self.dataArray = AddsHandler.sharedInstance.objCategoryArray
            self.categotyAdArray = AddsHandler.sharedInstance.objCategotyAdArray
            self.tableView.reloadData()
        }
        else if isFromNearBySearch {
            let param: [String: Any] = ["ad_cats1" : categoryID, "page_number": 1]
            print(param)
            self.adForest_categoryData(param: param as NSDictionary)
        }
        
        else {
            if isFromLocation {
                let param: [String: Any] = ["ad_country" : categoryID]
                print(param)
                self.adForest_categoryData(param: param as NSDictionary)
            }
            else {
                let param: [String: Any] = ["ad_cats1" : categoryID, "page_number": 1]
                print(param)
                self.adForest_categoryData(param: param as NSDictionary)
            }
        }
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func orderDropDown() {
        arrangeDropDown.anchorView = headerDropDownButton
        arrangeDropDown.dataSource = orderArray
        arrangeDropDown.selectionAction = { [unowned self] (index, item) in
            self.headerDropDownButton.setTitle(item, for: .normal)
            print("\(index, item)")
            let param: [String: Any] = ["ad_cats1" : self.categoryID, "page_number": 1, "sort": item.lowercased()]
            print(param)
            self.adForest_categoryData(param: param as NSDictionary)
        }
    }
    
    func goToDetailController(id: Int) {
        let addDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        addDetailVC.ad_id = id
        self.navigationController?.pushViewController(addDetailVC, animated: true)
    }
    
//    func showLocationButton() {
//        let button = UIButton(type: .custom)
//        let origImage = UIImage(named: "location")
//        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
//        button.setImage(tintedImage, for: .normal)
//        button.tintColor = .white
//
//        if #available(iOS 11, *) {
//            button.widthAnchor.constraint(equalToConstant: 20).isActive = true
//            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        }
//        else {
//            button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//        }
//        button.addTarget(self, action: #selector(onClickMapButton), for: .touchUpInside)
//
//        let barButton = UIBarButtonItem(customView: button)
//        navigationItem.rightBarButtonItem = barButton
//    }
    
//    @objc func onClickMapButton() {
//            let markerOnMaps = self.storyboard?.instantiateViewController(withIdentifier: "MarkersOnMapController") as! MarkersOnMapController
//            self.navigationController?.pushViewController(markerOnMaps, animated: true)
//    }
    
    //MARK:- Table View Delegate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if section == 0 {
            let cell: CategoryFeatureCell =  tableView.dequeueReusableCell(withIdentifier: "CategoryFeatureCell", for: indexPath) as! CategoryFeatureCell
            
            cell.dataArray = self.categotyAdArray
            cell.delegate = self
            cell.reloadData()
            return cell
        }
        else if section == 1 {
            let cell: CategoryCell =  tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let objData = dataArray[indexPath.row]
            
            for image in objData.images {
                if let imgUrl = URL(string: image.thumb) {
                    cell.imgPicture.sd_setShowActivityIndicatorView(true)
                    cell.imgPicture.sd_setIndicatorStyle(.gray)
                    cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                }
            }
            if let title = objData.adTitle {
                cell.lblName.text = title
            }
            if let location = objData.location.address {
                cell.lblLocation.text = location
            }
            if let price = objData.adPrice.price {
                cell.lblPrice.text = price
            }
            
            if let catName = objData.adCatsName {
                cell.lblPath.text = catName
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 1 {
            let addDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
            addDetailVC.ad_id = dataArray[indexPath.row].adId
            self.navigationController?.pushViewController(addDetailVC, animated: true)
        }
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
            let param: [String: Any] = ["ad_cats1" : categoryID, "page_number": currentPage]
            print(param)
            self.adForest_loadMoreData(param: param as NSDictionary)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        var height: CGFloat = 0.0
        
        if section == 0 {
            if AddsHandler.sharedInstance.isShowFeatureOnCategory {
                height = 240
            }
            else if isFromAdvanceSearch {
                if AddsHandler.sharedInstance.objCategotyAdArray.count == 0 {
                    height = 0
                }
                else {
                    height = 240
                }
            }
            else {
                height = 0
            }
        }
        else if section == 1 {
            height = 110
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width , height: 30))
        headerView.backgroundColor = UIColor.groupTableViewBackground
       
        if section == 0 {
                let titleLabel = UILabel(frame: CGRect(x: 20, y: 4, width: self.view.frame.size.width - 20 , height: 20))
                titleLabel.text = self.featureAddTitle
                titleLabel.font = UIFont.systemFont(ofSize: 15)
                titleLabel.textAlignment = .left
                titleLabel.backgroundColor = UIColor.groupTableViewBackground
                headerView.addSubview(titleLabel)
                return headerView
        }
        else {
            //titile label
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 5, width: 150 , height: 20))
            titleLabel.text = self.addcategoryTitle
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.textAlignment = .left
            titleLabel.backgroundColor = UIColor.groupTableViewBackground
        
            // image view
            let imgView = UIImageView(frame: CGRect(x: self.view.frame.width - 20, y: 8, width: 15, height: 15))
            imgView.image = #imageLiteral(resourceName: "arrowDown")
            imgView.contentMode = .scaleAspectFill
            
            //pop up button
            headerDropDownButton.frame = CGRect(x: self.view.frame.size.width - 160 , y: 0, width: 150, height: 30)
            headerDropDownButton.backgroundColor = UIColor.groupTableViewBackground
            headerDropDownButton.setTitle(orderName, for: .normal)
            headerDropDownButton.setTitleColor(UIColor.black, for: .normal)
            headerDropDownButton.addTarget(self, action: #selector(onClickHeaderButton), for: .touchUpInside)
            headerView.addSubview(headerDropDownButton)
            headerView.addSubview(titleLabel)
            headerView.addSubview(imgView)
            return headerView
        }
    }
    @objc func onClickHeaderButton() {
        print("Header Button")
        arrangeDropDown.show()
    }
    
    
    //MARK:- API Call
    func adForest_categoryData(param: NSDictionary) {
        self.showLoader()
        AddsHandler.categoryData(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.extra.title
                self.featureAddTitle = successResponse.data.featuredAds.text
                self.addcategoryTitle = successResponse.topbar.countAds
                self.currentPage = successResponse.pagination.currentPage
                self.maximumPage = successResponse.pagination.maxNumPages
                
                //set drop down data
                self.orderName = successResponse.topbar.sortArrKey.value
                self.orderArray = []
                for order in successResponse.topbar.sortArr {
                    self.orderArray.append(order.value)
                }
                self.orderDropDown()
                AddsHandler.sharedInstance.objCategory = successResponse
                AddsHandler.sharedInstance.isShowFeatureOnCategory = successResponse.extra.isShowFeatured
                self.dataArray = successResponse.data.ads
                self.categotyAdArray = successResponse.data.featuredAds.ads
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
    
    func adForest_loadMoreData(param: NSDictionary) {
        self.showLoader()
        AddsHandler.categoryData(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
             
                self.currentPage = successResponse.pagination.currentPage
                self.maximumPage = successResponse.pagination.maxNumPages
                
                AddsHandler.sharedInstance.objCategory = successResponse
                AddsHandler.sharedInstance.isShowFeatureOnCategory = successResponse.extra.isShowFeatured
                self.dataArray.append(contentsOf: successResponse.data.ads)
                self.categotyAdArray.append(contentsOf: successResponse.data.featuredAds.ads)
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
