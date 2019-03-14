//
//  AdPostMapController.swift
//  AdForest
//
//  Created by apple on 4/26/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import MapKit
import TextFieldEffects
import DropDown
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import NVActivityIndicatorView

class AdPostMapController: UITableViewController, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate , UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate, NVActivityIndicatorViewable, SubCategoryDelegate {
  
    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblUserinfo: UILabel!
    @IBOutlet weak var txtName: HoshiTextField!
    @IBOutlet weak var txtNumber: HoshiTextField!
    @IBOutlet weak var containerViewPopup: UIView! {
        didSet {
            containerViewPopup.addShadowToView()
        }
    }
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var oltPopup: UIButton! {
        didSet {
            oltPopup.contentHorizontalAlignment = .left
        }
    }
    @IBOutlet weak var containerViewAddress: UIView!
    @IBOutlet weak var txtAddress: HoshiTextField! {
        didSet{
            txtAddress.delegate = self
        }
    }
    @IBOutlet weak var containerViewMap: UIView!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            
        }
    }
    @IBOutlet weak var txtLatitude: HoshiTextField!
    @IBOutlet weak var txtLongitude: HoshiTextField!
    @IBOutlet weak var containerViewFeatureAdd: UIView! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                containerViewFeatureAdd.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var lblFeatureAdd: UILabel!
    @IBOutlet weak var oltCheck: UIButton!
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var oltPostAdd: UIButton! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltPostAdd.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    //MARK:- Properties
    let locationDropDown = DropDown()
    lazy var dropDowns : [DropDown] = {
        return [
            self.locationDropDown
        ]
    }()
    
    var popUpArray = [String]()
    var hasSubArray = [Bool]()
    var locationIdArray = [String]()
    
    var hasSub = false
    var selectedID = ""
    
    var popUpTitle = ""
    var popUpConfirm = ""
    var popUpCancel = ""
    var popUpText = ""
    
    let locationManager = CLLocationManager()
    let newPin = MKPointAnnotation()
    let regionRadius: CLLocationDistance = 1000
    var initialLocation = CLLocation(latitude: 25.276987, longitude: 55.296249)
    
    var latitude = ""
    var longitude = ""
   // var objFieldData = [AdPostField]()
    var valueArray = [String]()
    
    var localVariable = ""
    
    //this array get data from previous controller
    var objArray = [AdPostField]()
    
    
    var imageIdArray = [Int]()
    var descriptionText = ""
    
    var addInfoDictionary = [String: Any]()
    var customDictionary = [String: Any]()
    var customArray = [AdPostField]()
    var imageArray = AddsHandler.sharedInstance.adPostImagesArray
    // get values in populate data and send it with parameters
    var phone_number = ""
    var address = ""
    
    var isFeature = "false"
    var localDictionary = [String: Any]()
    
    var selectedCountry = ""
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.adForest_populateData()
        let map = GMSMapView()
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        
        for item in objArray {
           print(item.fieldTypeName, item.fieldName, item.fieldVal, item.fieldType)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Text Field Delegate Method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let searchVC = GMSAutocompleteViewController()
        searchVC.delegate = self
        self.presentVC(searchVC)
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    
    func adForest_populateData() {
        if AddsHandler.sharedInstance.objAdPost != nil {
            let objData = AddsHandler.sharedInstance.objAdPost
            
            if let pageTitle = objData?.data.title {
                self.title = pageTitle
            }
            if let infoText = objData?.extra.userInfo {
                self.lblUserinfo.text = infoText
            }
            if let nameText = objData?.data.profile.name.title {
                self.txtName.placeholder = nameText
            }
            if  let name = objData?.data.profile.name.fieldVal {
                self.txtName.text = name
            }
            
            if let nmbrText = objData?.data.profile.phone.title {
                self.txtNumber.placeholder = nmbrText
            }
            if let nmbr = objData?.data.profile.phone.fieldVal {
                self.txtNumber.text = nmbr
                self.phone_number = nmbr
            }
            
            var isPhoneEdit = false
            if let editNumber = objData?.data.profile.phoneEditable {
                isPhoneEdit = editNumber
            }
            
            if isPhoneEdit {
                self.txtNumber.isEnabled = true
            }
            else if isPhoneEdit == false {
                self.txtNumber.isEnabled = false
            }
            
            if let addressText = objData?.data.profile.location.title {
                self.txtAddress.placeholder = addressText
            }
            
            if let addressValue = objData?.data.profile.location.fieldVal {
                self.txtAddress.text = addressValue
                self.address = addressValue
            }
            
            guard let isMapShow = objData?.data.profile.map.onOff else {
                return
            }
            
            if isMapShow {
                
                if let latText = objData?.data.profile.map.locationLat.title {
                    self.txtLatitude.placeholder = latText
                }
                
                if let latValue =  objData?.data.profile.map.locationLat.fieldVal {
                    self.txtLatitude.text = latValue
                }
                
                if let longText = objData?.data.profile.map.locationLong.title {
                    self.txtLongitude.placeholder = longText
                }
                
                if let longValue = objData?.data.profile.map.locationLong.fieldVal {
                    self.txtLongitude.text = longValue
                }
                if let lat = objData?.data.profile.map.locationLat.fieldVal {
                    self.latitude = lat
                }
                if let long = objData?.data.profile.map.locationLong.fieldVal {
                    self.longitude = long
                }
                
                if latitude != "" && longitude != "" {
                    initialLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
                }
                self.centerMapOnLocation(location: initialLocation)
                self.addAnnotations(coords: [initialLocation])
                self.setupView()
            }
                
            else if isMapShow == false {
                containerViewMap.isHidden = true
                containerViewFeatureAdd.translatesAutoresizingMaskIntoConstraints = false
                containerViewFeatureAdd.topAnchor.constraint(equalTo: self.containerViewAddress.bottomAnchor, constant: 8).isActive = true
            }
            
            guard let isShowCountry = objData?.data.profile.adCountryShow else {
                return
            }
            if isShowCountry {
                for values in (objData?.data.profile.adCountry.values)! {
                    var i = 1
                    if values.id == "" {
                        continue
                    }
                    self.popUpArray.append(values.name)
                    self.hasSubArray.append(values.hasSub)
                    self.locationIdArray.append(String(values.id))
                    if i == 1 {
                        self.oltPopup.setTitle(values.name, for: .normal)
                    }
                    
                    i = i + 1
                }
                //location popup method call here after asigning data
                self.locationPopup()
            }
                
            else if isShowCountry == false {
                self.containerViewPopup.isHidden = true
                containerViewAddress.translatesAutoresizingMaskIntoConstraints = false
                containerViewAddress.topAnchor.constraint(equalTo: self.txtNumber.bottomAnchor, constant: 8).isActive = true
            }
            
            if let locationText = objData?.data.profile.adCountry.title {
                self.lblLocation.text = locationText
            }
            
            guard let featuredAdBuy = objData?.data.profile.featuredAdBuy else {
                return
            }
            
            if featuredAdBuy {
                if let checkButtonTitle = objData?.data.profile.featuredAdNotify.btn {
                    self.oltCheck.setTitle(checkButtonTitle, for: .normal)
                    self.oltCheck.backgroundColor = Constants.hexStringToUIColor(hex: "#00a2ff")
                    imgCheckBox.image = nil
                }
                if let featureTitle = objData?.data.profile.featuredAdNotify.text {
                    self.lblFeatureAdd.text = featureTitle
                }
            }
            
            guard let featureAdShow = objData?.data.profile.featuredAdIsShow else {
                return
            }
            
             if featureAdShow {
                  imgCheckBox.image = #imageLiteral(resourceName: "uncheck")
                if let featureAdText = objData?.data.profile.featuredAd.title {
                    self.lblFeatureAdd.text = featureAdText
                }
                
                if let titlePop = objData?.data.profile.featuredAdText.title {
                    self.popUpTitle = titlePop
                }
                if let textPop = objData?.data.profile.featuredAdText.text {
                    self.popUpText = textPop
                }
                if let okPop = objData?.data.profile.featuredAdText.btnOk {
                    self.popUpConfirm = okPop
                }
                
                if let cancelPop = objData?.data.profile.featuredAdText.btnNo {
                    self.popUpCancel = cancelPop
                }
            }
            if featureAdShow == false && featuredAdBuy == false {
                        containerViewFeatureAdd.isHidden = true
            }
            
//             else if featureAdShow == false {
//                containerViewFeatureAdd.isHidden = true
//            }
            
            if let postButtonTitle =  objData?.data.btnSubmit {
                self.oltPostAdd.setTitle(postButtonTitle, for: .normal)
            }

        }
    }
    
    
    //MARK:- SetUp Drop Down
    func locationPopup() {
        locationDropDown.anchorView = oltPopup
        locationDropDown.dataSource = popUpArray
        locationDropDown.selectionAction = { [unowned self]
            (index, item) in
            self.oltPopup.setTitle(item, for: .normal)
            self.selectedCountry = item
            self.hasSub = self.hasSubArray[index]
            self.selectedID = self.locationIdArray[index]
            
            if self.hasSub {
                let param: [String: Any] = ["ad_country" : self.selectedID]
                print(param)
                self.adForest_subLocations(param: param as NSDictionary)
            }
        }
    }
    
    //MARK:- Sub Locations Delegate Method

    func subCategoryDetails(name: String, id: Int, hasSubType: Bool, hasTempelate: Bool, hasCatTempelate: Bool) {
        if hasSubType {
            let param: [String: Any] = ["ad_country" : id]
            print(param)
            self.adForest_subLocations(param: param as NSDictionary)
        }
        else {
            self.oltPopup.setTitle(name, for: .normal)
            self.selectedID = String(id)
        }
    }
    
   
    // Google Places Delegate Methods
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place Name : \(place.name)")
        print("Place Address : \(place.formattedAddress ?? "null")")
        txtAddress.text = place.formattedAddress
        self.address = place.formattedAddress!
        self.txtLatitude.text = String(place.coordinate.latitude)
        self.txtLongitude.text = String(place.coordinate.longitude)
        self.latitude = String(place.coordinate.latitude)
        self.longitude = String(place.coordinate.longitude)
        self.dismissVC(completion: nil)
        
        if latitude != "" && longitude != "" {
            initialLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        }
        self.centerMapOnLocation(location: initialLocation)
        self.addAnnotations(coords: [initialLocation])
        self.setupView()
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.dismissVC(completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismissVC(completion: nil)
    }
    
    //MARK:- Map View Delegate Methods
    
    func setupView (){
        mapView.delegate = self
        mapView.showsUserLocation = true
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Map
    func centerMapOnLocation (location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func addAnnotations(coords: [CLLocation]){
        for coord in coords{
            let CLLCoordType = CLLocationCoordinate2D(latitude: coord.coordinate.latitude,
                                                      longitude: coord.coordinate.longitude);
            let anno = MKPointAnnotation();
            anno.coordinate = CLLCoordType;
            mapView.addAnnotation(anno);
        }
    }
    
    private func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else {
            let pinIdent = "Pin"
            var pinView: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent);
            }
            return pinView;
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.latitude = String(location.coordinate.latitude)
        self.longitude = String(location.coordinate.longitude)
        self.txtLatitude.text = self.latitude
        self.txtLongitude.text = self.longitude
        self.mapView.setRegion(region, animated: true)
    }
    
    //MARK:- IBActions
    
    @IBAction func actionPopup(_ sender: Any) {
        locationDropDown.show()
    }
    
    @IBAction func actionCheck(_ sender: Any) {
        if AddsHandler.sharedInstance.objAdPost != nil {
            let objData = AddsHandler.sharedInstance.objAdPost
            
            guard let isFeatureBuy = objData?.data.profile.featuredAdBuy else {
                return
            }
            
            if isFeatureBuy {
                if let featureTitle = objData?.data.profile.featuredAdNotify.text {
                    self.showToast(message: featureTitle)
                }
            }
            else if isFeatureBuy == false {
                self.imgCheckBox.image = #imageLiteral(resourceName: "check")
                
                let alert = UIAlertController(title: popUpTitle, message: popUpText, preferredStyle: .alert)
                
                let confirm = UIAlertAction(title: popUpConfirm, style: .default) { (action) in
                    self.imgCheckBox.image = #imageLiteral(resourceName: "check")
                    self.isFeature = "true"
                }
                let cancel = UIAlertAction(title: popUpCancel, style: .default) { (action) in
                    self.imgCheckBox.image = #imageLiteral(resourceName: "uncheck")
                }
                alert.addAction(cancel)
                alert.addAction(confirm)
                self.presentVC(alert)
            }
        }
    }
    
    @IBAction func actionPostAdd(_ sender: Any) {
        if address == "" {
            let alert = Constants.showBasicAlert(message: "Location Required")
            self.presentVC(alert)
        }
        else {
            var parameter: [String: Any] = [
                "images_array": imageIdArray,
                "ad_phone": phone_number,
                "ad_location":  address,
                "location_lat": latitude,
                "location_long": longitude,
                "ad_country": selectedCountry,
                "ad_featured_ad": isFeature,
                "ad_id": AddsHandler.sharedInstance.adPostAdId
            ]
            print(parameter)
            let dataArray = objArray
            
            for (_, value) in dataArray.enumerated() {
                if value.fieldVal == "" {
                    continue
                }
                if customArray.contains(where: { $0.fieldTypeName == value.fieldTypeName}) {
                    customDictionary[value.fieldTypeName] = value.fieldVal
                    
                    print(customDictionary)
                }
                else {
                    addInfoDictionary[value.fieldTypeName] = value.fieldVal
                    print(addInfoDictionary)
                }
            }
            customDictionary.merge(with: localDictionary)
            let custom = Constants.json(from: customDictionary)
            print(custom)
            if AddsHandler.sharedInstance.isCategoeyTempelateOn {
                let param: [String: Any] = ["custom_fields": custom!]
                parameter.merge(with: param)
            }
            parameter.merge(with: addInfoDictionary)
            print(parameter)
             //self.dummy(param: parameter as NSDictionary)
            self.adForest_postAd(param: parameter as NSDictionary)
        }
    }
    
    //Dummy request
    func dummy(param: NSDictionary) {
        AddsHandler.dummy(parameter: param, success: { (successresponse) in
            print(successresponse)
        }) { (error) in
            print(error)
        }
    }
    
    
    //MARK:- API Call
    //Post Add
    func adForest_postAd(param: NSDictionary) {
        self.showLoader()
        AddsHandler.adPostLive(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.navigationController?.popToRootViewController(animated: true)
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
    
    // sub locations
    func adForest_subLocations(param: NSDictionary) {
        self.showLoader()
        AddsHandler.adPostSubLocations(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                AddsHandler.sharedInstance.objSearchCategory = successResponse.data
                let searchCatVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchCategoryDetail") as! SearchCategoryDetail
                searchCatVC.dataArray = successResponse.data.values
                searchCatVC.modalPresentationStyle = .overCurrentContext
                searchCatVC.modalTransitionStyle = .crossDissolve
                searchCatVC.delegate = self
                self.presentVC(searchCatVC)
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
