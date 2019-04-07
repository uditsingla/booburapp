//
//  MarkersOnMapController.swift
//  AdForest
//
//  Created by Abhishek Singla on 23/02/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import GoogleMaps
import NVActivityIndicatorView


class MarkersOnMapController: UIViewController,GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {

    //MARK:- Properties
    var isAllPlacesRequired : Bool = false
    var delegate :leftMenuProtocol?
    @IBOutlet weak var viewMap: GMSMapView!
    var dataArray = [CategoryAd]()
    var arrMarkers = [GMSMarker]()
    var clickedMarkerWindowIndex = 0
    
    var isFromLocation = false
    
    var categotyAdArray = [CategoryAd]()
    
    var currentPage = 0
    var maximumPage = 0
    
    var featureAddTitle = ""
    var addcategoryTitle = ""
    
    var orderArray = [String]()
    var orderName = ""
    
    var isFromAdvanceSearch = false
    var isFromNearBySearch = false
    
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var nearByDistance: CGFloat = 0.0

    @IBOutlet weak var collectionview: UICollectionView!{
        didSet {
            collectionview.delegate = self
            collectionview.dataSource = self
            collectionview.showsVerticalScrollIndicator = false
            collectionview.showsHorizontalScrollIndicator = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.viewMap.delegate = self
        setMapsData(categoryData: AddsHandler.sharedInstance.objCategoryArray)
        self.showLocationButton()
        self.addBackButtonToNavigationBar()
        self.title = "Search Results"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if isAllPlacesRequired{
            let dictInternal : NSMutableDictionary = NSMutableDictionary()
            let dictMain : NSMutableDictionary = NSMutableDictionary()
            dictMain.setValue(dictInternal, forKey: "custom_fields")
            self.adForest_postData(parameter: dictMain)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        isAllPlacesRequired = false
    }
    
    //MARK:- Custom
    
    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        if isAllPlacesRequired {
            self.delegate?.changeViewController(.main)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func setMapsData(categoryData : [CategoryAd]){
        if categoryData.count>0{
            self.dataArray = categoryData
            self.setMarkers()
            collectionview.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            collectionview.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionview.delegate?.collectionView!(collectionview, didSelectItemAt: indexPath)
        }
    }
    
    func showLocationButton() {
        let button = UIButton(type: .custom)
        let origImage = UIImage(named: "list")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .white
        
        if #available(iOS 11, *) {
            button.widthAnchor.constraint(equalToConstant: 20).isActive = true
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        else {
            button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        }
        button.addTarget(self, action: #selector(onClickMapButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func onClickMapButton() {
        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
        categoryVC.isFromAdvanceSearch = true
        categoryVC.featureAddTitle = self.featureAddTitle
        categoryVC.addcategoryTitle = self.addcategoryTitle
        categoryVC.currentPage = self.currentPage
        categoryVC.maximumPage = self.maximumPage
        categoryVC.title = self.title
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    func setMarkers(){
        for (index,data) in dataArray.enumerated() {
            let locationMarker = GMSMarker()
            let coordinate = CLLocationCoordinate2D(latitude: (Double(data.location.lat) ?? 0.0), longitude: (Double(data.location.longField) ?? 0.0))
            locationMarker.position = coordinate
            locationMarker.title = data.location?.title!
            locationMarker.snippet = data.location?.address!
            locationMarker.appearAnimation = .pop
            locationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
            locationMarker.map = viewMap
            
            if index == 0{
                self.viewMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 14.0)
                viewMap.selectedMarker = locationMarker
                locationMarker.icon = GMSMarker.markerImage(with: UIColor.orange)
            }
            arrMarkers.append(locationMarker)
        }
    }
    
    //MARK:- API Hit
    func adForest_postData(parameter : NSDictionary) {
        self.showLoader()
        AddsHandler.searchData(parameter: parameter, success: { (successResponse) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if successResponse.success {
                AddsHandler.sharedInstance.objCategoryArray = successResponse.data.ads
                AddsHandler.sharedInstance.objCategotyAdArray = successResponse.data.featuredAds.ads
                self.isFromAdvanceSearch = false
                self.featureAddTitle = successResponse.data.featuredAds.text
                self.addcategoryTitle = successResponse.topbar.countAds
                self.currentPage = successResponse.pagination.currentPage
                self.maximumPage = successResponse.pagination.maxNumPages
                self.title = successResponse.extra.title
                self.setMapsData(categoryData: AddsHandler.sharedInstance.objCategoryArray)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.presentVC(alert)
            }
        }) { (error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.presentVC(alert)
        }
    }

    
    //MARK:- Custom Functions
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    
    //MARK:- GMS View Delegate Method
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        for marker in arrMarkers{
            marker.icon = GMSMarker.markerImage(with: .red)
        }
        
        if let index = arrMarkers.index(of: marker) {
            let data = dataArray[index]
            let coordinate = CLLocationCoordinate2D(latitude: (Double(data.location.lat) ?? 0.0), longitude: (Double(data.location.longField) ?? 0.0))
            self.viewMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 14.0)
            self.collectionview.scrollToItem(at:IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            marker.icon = GMSMarker.markerImage(with: UIColor.orange)
            viewMap.selectedMarker = marker
            marker.map = viewMap
            clickedMarkerWindowIndex = index
        
            let indexPath = IndexPath(row: index, section: 0)
            collectionview.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            collectionview.delegate?.collectionView!(collectionview, didSelectItemAt: indexPath)
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Window clicked")
        let addDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AddDetailController") as! AddDetailController
        addDetailVC.ad_id = dataArray[clickedMarkerWindowIndex].adId
        self.navigationController?.pushViewController(addDetailVC, animated: true)
    }
                
    //MARK:- Collection View Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.isHidden = dataArray.count == 0
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionCell
        let objData = dataArray[indexPath.row]
        
        for images in objData.images {
            if let imgUrl = URL(string: images.thumb) {
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
            }
        }
        if let lblFeature = objData.adCatsName {
            cell.lblFeature.text = lblFeature
        }
        if let name = objData.adTitle {
            cell.lblName.text = name
        }
        if let location = objData.location {
            cell.lblLocation.text = location.address
        }
        if let price = objData.adPrice.price {
            cell.lblPrice.text = price
        }
        
        let view = UIView(frame: cell.bounds)
        view.backgroundColor = .orange
        cell.selectedBackgroundView = view
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 140, height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = dataArray[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: (Double(data.location.lat) ?? 0.0), longitude: (Double(data.location.longField) ?? 0.0))
        self.viewMap.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 14.0)
        let markerObj = arrMarkers[indexPath.row]
        clickedMarkerWindowIndex = indexPath.row
        for marker in arrMarkers{
            marker.icon = GMSMarker.markerImage(with: .red)
        }
        markerObj.icon = GMSMarker.markerImage(with: .orange)
        viewMap.selectedMarker = markerObj
        markerObj.map = viewMap
        
        collectionview.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}


