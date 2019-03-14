//
//  AdvancedSearchController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView
import DropDown
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import Alamofire
import RangeSeekSlider

class AdvancedSearchController: UIViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource {

    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorStyle = .none
        }
    }
    
    //MARK:- Properties
    var delegate :leftMenuProtocol?
    var dataArray = [SearchData]()
    
    var data = [SearchData]()
    var addInfoDictionary = [String: Any]()
    var customDictionary = [String: Any]()
    var isAdd = false
    var newArray = [SearchData]()
    var dynamicArray = [SearchData]()
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshButton()
        self.addBackButtonToNavigationBar()
        self.adForest_getSearchData()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.searchDynamicData), object: nil, queue: nil) { (notification) in
            self.dataArray = self.newArray
            self.dynamicArray = AddsHandler.sharedInstance.objSearchArray
            self.dataArray.insert(contentsOf: AddsHandler.sharedInstance.objSearchArray, at: 2)
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Advanced Search Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    //MARK:- Custom

    func addBackButtonToNavigationBar() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backbutton"), style: .done, target: self, action: #selector(moveToParentController))
        leftButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func moveToParentController() {
        self.delegate?.changeViewController(.main)
    }
    
    func refreshButton() {
        let button = UIButton(type: .custom)
        let origImage = UIImage(named: "search")
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
        button.addTarget(self, action: #selector(onClickRefreshButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func onClickRefreshButton() {
        for index in 0..<dataArray.count {
            if let objData = dataArray[index] as? SearchData {
                
                if objData.fieldType == "select" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchDropDown {
                        var obj = SearchData()
                        
                        obj.fieldTypeName = cell.param
                        obj.fieldVal = cell.selectedKey
                        obj.fieldType = "select"
                        data.append(obj)
                    }
                }
                if objData.fieldType == "textfield" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchTextField {
                        var obj = SearchData()
                        
                        obj.fieldType = "textfield"
                        obj.fieldVal = cell.txtType.text
                        obj.fieldTypeName = cell.fieldName
                        data.append(obj)
                    }
                }
                
                if objData.fieldType == "range_textfield" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchTwoTextField {
                        var obj = SearchData()
                        
                        obj.fieldType = "range_textfield"
                        obj.fieldTypeName = cell.fieldName
                        guard let minTF = cell.txtMinPrice.text else {
                            return
                        }
                        guard let maxTF = cell.txtmaxPrice.text else {
                            return
                        }
                        let rangeTF = minTF + "-" + maxTF
                        obj.fieldVal = rangeTF
                        data.append(obj)
                    }
                }
                
                if objData.fieldType == "glocation_textfield" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchAutoCompleteTextField {
                          var obj = SearchData()
                        
                        obj.fieldType = "glocation_textfield"
                        obj.fieldTypeName = cell.fieldName
                        obj.fieldVal = cell.txtAutoComplete.text
                        data.append(obj)
                    }
                }
                
                if objData.fieldType == "seekbar" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SeekBar {
                        var obj = SearchData()
                        
                        obj.fieldType = "seekbar"
                        obj.fieldTypeName = cell.fieldName
                        obj.fieldVal = String(cell.maximumValue)
                        data.append(obj)
                    }
                }
            }
        }
        self.setUpData()
    }
    //Set Up parameters to Sent to Server
    func setUpData() {
        let dataToSend = data
        for (key, value) in dataToSend.enumerated() {
            if value.fieldVal == "" {
                continue
            }
            if newArray.contains(where: { $0.fieldTypeName == value.fieldTypeName}) {
                addInfoDictionary[value.fieldTypeName] = value.fieldVal
                print(addInfoDictionary)
            } else {
                customDictionary[value.fieldTypeName] = value.fieldVal
                print(customDictionary)
            }
        }

        let custom = Constants.json(from: customDictionary)
        var param: [String: Any] = ["custom_fields": custom]
        param.merge(with: addInfoDictionary)
      
        self.adForest_postData(parameter: param as NSDictionary)
    }
    
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objData = dataArray[indexPath.row]
      
        if objData.fieldType == "select" {
            let cell: SearchDropDown = tableView.dequeueReusableCell(withIdentifier: "SearchDropDown", for: indexPath) as! SearchDropDown
           
            if let title = objData.title {
                cell.lblName.text = title
            }
           
            var i = 1
            for item in objData.values {
                if item.id == "" {
                    continue
                }
                if i == 1 {
                    cell.oltPopup.setTitle(item.name, for: .normal)
                }
                i = i + 1
            }
            cell.btnPopupAction = { () in
                cell.dropDownKeysArray = []
                cell.dropDownValuesArray = []
                cell.fieldTypeName = []
                cell.hasSubArray = []
                cell.hasTemplateArray = []
                cell.hasCategoryTempelateArray = []
                
                for item in objData.values {
                    if item.id == "" {
                        continue
                    }
                    cell.dropDownKeysArray.append(item.id)
                    cell.dropDownValuesArray.append(item.name)
                    cell.fieldTypeName.append(objData.fieldTypeName)
                    cell.hasSubArray.append(item.hasSub)
                    cell.hasTemplateArray.append(item.hasTemplate)
                    cell.hasCategoryTempelateArray.append(objData.hasCatTemplate)
                }
                cell.accountDropDown()
                cell.valueDropDown.show()
            }
            return cell
        }
        
        else if objData.fieldType == "radio" {
            let cell: RadioButtonCell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonCell", for: indexPath) as! RadioButtonCell
            
            if let title = objData.title {
                cell.lblTitle.text = title
            }
            
            cell.dataArray = objData.values
            cell.tableView.reloadData()
            return cell
        }
            
//        else if objData.fieldType == "textfield" {
//            let cell: SearchTextField = tableView.dequeueReusableCell(withIdentifier: "SearchTextField", for: indexPath) as! SearchTextField
//            
//            if let txtTitle = objData.title {
//                cell.txtType.placeholder = txtTitle
//            }
//            if let fieldValue = objData.fieldVal {
//                cell.txtType.text = fieldValue
//            }
//            cell.fieldName = objData.fieldTypeName
//            return cell
//        }
        
        else if objData.fieldType == "range_textfield" {
            let cell : SearchTwoTextField = tableView.dequeueReusableCell(withIdentifier: "SearchTwoTextField", for: indexPath) as! SearchTwoTextField
            
            if let title = objData.title {
                cell.lblMin.text = title
            }
            if let minTitle = objData.data[0].title {
                cell.txtMinPrice.placeholder = minTitle
            }
            if let maxTitle = objData.data[1].title {
                cell.txtmaxPrice.placeholder = maxTitle
            }
            cell.fieldName = objData.fieldTypeName
            return cell
        }
            
//        else if objData.fieldType == "glocation_textfield" {
//            let cell: SearchAutoCompleteTextField = tableView.dequeueReusableCell(withIdentifier: "SearchAutoCompleteTextField", for: indexPath) as! SearchAutoCompleteTextField
//
//            if let txtTitle = objData.title {
//                cell.txtAutoComplete.placeholder = txtTitle
//            }
//
//            if let fieldValue = objData.fieldVal {
//                cell.txtAutoComplete.text = fieldValue
//            }
//            cell.fieldName = objData.fieldTypeName
//            return cell
//            }
        else if objData.fieldType == "seekbar" {
            let cell: SeekBar = tableView.dequeueReusableCell(withIdentifier: "SeekBar", for: indexPath) as! SeekBar
            if let title = objData.title {
                cell.lblTitle.text = title
            }
            cell.fieldName = objData.fieldTypeName
            
            return cell
        }
            return UITableViewCell()
        }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let objData = dataArray[indexPath.row]
        if objData.fieldType == "radio" {
            return 120
        }
        return 80
    }
    //MARK:- API Calls
    
    func adForest_getSearchData() {
        self.showLoader()
        AddsHandler.advanceSearch(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.extra.title
                self.dataArray = successResponse.data
                self.newArray = successResponse.data
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
    
    //post data to search
    func adForest_postData(parameter : NSDictionary) {
        self.showLoader()
        AddsHandler.searchData(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let markersOnMapVC = self.storyboard?.instantiateViewController(withIdentifier: "MarkersOnMapController") as! MarkersOnMapController
                AddsHandler.sharedInstance.objCategoryArray = successResponse.data.ads
                AddsHandler.sharedInstance.objCategotyAdArray = successResponse.data.featuredAds.ads
                markersOnMapVC.isFromAdvanceSearch = true
                markersOnMapVC.featureAddTitle = successResponse.data.featuredAds.text
                markersOnMapVC.addcategoryTitle = successResponse.topbar.countAds
                markersOnMapVC.currentPage = successResponse.pagination.currentPage
                markersOnMapVC.maximumPage = successResponse.pagination.maxNumPages
                markersOnMapVC.title = successResponse.extra.title
                self.navigationController?.pushViewController(markersOnMapVC, animated: true)
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


//MARK:- search Cell Classes


class SearchDropDown: UITableViewCell, NVActivityIndicatorViewable , SubCategoryDelegate {
   
    //MARK:- Outlets
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var oltPopup: UIButton!

    //MARK:- Properties
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var dropDownKeysArray = [String]()
    var dropDownValuesArray = [String]()
    var fieldTypeName = [String]()
    var hasSubArray = [Bool]()
    var hasTemplateArray = [Bool]()
    var hasCategoryTempelateArray = [Bool]()
    
    
    var btnPopupAction : (()->())?
    let appDel = UIApplication.shared.delegate as! AppDelegate
    let valueDropDown = DropDown()
    lazy var dropDowns : [DropDown] = {
        return [
            self.valueDropDown
        ]
    }()
    
    var selectedKey = ""
    var selectedValue = ""
    var param = ""
    var fieldName = ""
    var hasSub = false
    var hasTempelate = false
    var hasCategoryTempelate = false
    
    
    //MARK:- View Life Cycle
     override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
     }
    
    //MARK:- SetUp Drop Down
    func accountDropDown() {
        valueDropDown.anchorView = oltPopup
        valueDropDown.dataSource = dropDownValuesArray
        valueDropDown.selectionAction = { [unowned self]
            (index, item) in
            self.oltPopup.setTitle(item, for: .normal)
            self.selectedKey = self.dropDownKeysArray[index]
            self.selectedValue = item
            self.param = self.fieldTypeName[index]
            print(self.param)
            self.hasSub = self.hasSubArray[index]
            self.hasTempelate = self.hasTemplateArray[index]
            self.hasCategoryTempelate = self.hasCategoryTempelateArray[index]
           
            if self.hasCategoryTempelate {
                if self.hasTempelate {
                    let param: [String: Any] = ["cat_id" : self.selectedKey]
                    print(param)
                    self.adForest_dynamicSearch(param: param as NSDictionary)
                }
            }
            
            if self.hasSub {
                if self.param == "ad_country" {
                    let url = Constants.URL.baseUrl+Constants.URL.categorySublocations
                    print(url)
                    let param: [String: Any] = ["ad_country": self.selectedKey]
                    self.adForest_subCategory(url: url, param: param as NSDictionary)
                }
                else {
                    let param: [String: Any] = ["subcat": self.selectedKey]
                    print(param)
                    let url = Constants.URL.baseUrl+Constants.URL.subCategory
                    print(url)
                    self.adForest_subCategory(url: url, param: param as NSDictionary)
                }
            }
        }
    }
    
    //MARK:- Delegate Method
    
    func subCategoryDetails(name: String, id: Int, hasSubType: Bool, hasTempelate: Bool, hasCatTempelate: Bool) {
        print(name, id, hasSubType, hasTempelate, hasCatTempelate)
        if hasSubType {
            if self.param == "ad_country" {
                let url = Constants.URL.baseUrl+Constants.URL.categorySublocations
                print(url)
                let param: [String: Any] = ["ad_country": id]
                print(param)
                self.adForest_subCategory(url: url, param: param as NSDictionary)
            }
            else {
                let param: [String: Any] = ["subcat": id]
                print(param)
                let url = Constants.URL.baseUrl+Constants.URL.subCategory
                print(url)
                self.adForest_subCategory(url: url, param: param as NSDictionary)
            }
        }
        else {
            oltPopup.setTitle(name, for: .normal)
            self.selectedKey = String(id)
            self.selectedValue = name
        }
    }
    
     @IBAction func actionPopup(_ sender: Any) {
        self.btnPopupAction?()
    }
    
    //MARK:- API Call
    func adForest_subCategory(url: String ,param: NSDictionary) {
        let searchObj = AdvancedSearchController()
        searchObj.showLoader()
        AddsHandler.subCategory(url: url, parameter: param, success: { (successResponse) in
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if successResponse.success {
                AddsHandler.sharedInstance.objSearchCategory = successResponse.data
                let seacrhCatVC = self.storyboard.instantiateViewController(withIdentifier: "SearchCategoryDetail") as! SearchCategoryDetail
                
                seacrhCatVC.dataArray = successResponse.data.values
                seacrhCatVC.modalPresentationStyle = .overCurrentContext
                seacrhCatVC.modalTransitionStyle = .crossDissolve
                seacrhCatVC.delegate = self
                self.appDel.presentController(ShowVC: seacrhCatVC)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.appDel.presentController(ShowVC: alert)
            }
        }) { (error) in
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.appDel.presentController(ShowVC: alert)
        }
    }
    
    //Dynamic Search
    func adForest_dynamicSearch(param: NSDictionary) {
        let searchObj = AdvancedSearchController()
        searchObj.showLoader()
        AddsHandler.dynamicSearch(parameter: param, success: { (successResponse) in
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if successResponse.success {
                AddsHandler.sharedInstance.objSearchArray = successResponse.data
                AddsHandler.sharedInstance.objSearchData = successResponse.data
                NotificationCenter.default.post(name:NSNotification.Name(Constants.NotificationName.searchDynamicData), object: nil)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.appDel.presentController(ShowVC: alert)
            }
        }) { (error) in
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.appDel.presentController(ShowVC: alert)
        }
    }
 }

class SearchTextField: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtType: UITextField!
    
    var fieldName = ""
    
     //MARK:- View Life Cycle
     override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
     }
 }




class SearchTwoTextField: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtMinPrice: UITextField!
    @IBOutlet weak var txtmaxPrice: UITextField!
    @IBOutlet weak var lblMin: UILabel!
   
    //MARK:- Properties
    
    var fieldName = ""
    
     //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}



class SearchAutoCompleteTextField: UITableViewCell, UITextFieldDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtAutoComplete: UITextField! {
        didSet {
            txtAutoComplete.delegate = self
        }
    }
    
    
    //MARK:- Properties
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var fieldName = ""
     //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    //MARK:- Text Field Delegate Method
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let searchVC = GMSAutocompleteViewController()
        searchVC.delegate = self
        self.window?.rootViewController?.present(searchVC, animated: true, completion: nil)
    }
    
    // Google Places Delegate Methods
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place Name : \(place.name)")
        print("Place Address : \(place.formattedAddress ?? "null")")
        txtAutoComplete.text = place.formattedAddress
        self.appDel.dissmissController()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        self.appDel.dissmissController()
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Cancelled")
        self.appDel.dissmissController()
    }
}

class SeekBar : UITableViewCell , RangeSeekSliderDelegate{
    
    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView!{
        didSet{
             containerView.addShadowToView()
        }
    }
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    @IBOutlet weak var lblTitle: UILabel!
    
    //MARK:- Properties
    var minimumValue = 0
    var maximumValue = ""
    var fieldName = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rangeSlider.delegate = self
        rangeSlider.disableRange = true
        rangeSlider.enableStep = true
        rangeSlider.step = 5
        if let bgColor = UserDefaults.standard.string(forKey: "mainColor") {
            rangeSlider.tintColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.minLabelColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.maxLabelColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.handleColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.handleBorderColor = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.colorBetweenHandles = Constants.hexStringToUIColor(hex: bgColor)
            rangeSlider.initialColor = Constants.hexStringToUIColor(hex: bgColor)
        }
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === rangeSlider {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
            let mxValue = maxValue
            self.maximumValue = "\(mxValue)"
        }
    }
    
    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}


class RadioButtonCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    //MARK:- Properties
    var dataArray = [SearchValue]()
    
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RadioButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RadioButtonTableViewCell", for: indexPath) as! RadioButtonTableViewCell
            let objData = dataArray[indexPath.row]
        if let title = objData.name {
            cell.lblName.text = title
        }
        print(objData.isSelected, indexPath.row)
        
        if objData.isSelected {
            cell.buttonRadio.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
        }else {
            cell.buttonRadio.setBackgroundImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
       
        cell.initializeData(value: objData, radioButtonCellRef: self, index: indexPath.row)
        //cell.initCellItem()
        return cell
    }
}


class RadioButtonTableViewCell : UITableViewCell {
   
    //MARK:- Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var buttonRadio: UIButton!
    
    
    // var dataArray = [SearchValue]()
    var data : SearchValue?
    var radioButtonCell: RadioButtonCell!
    var indexPath = 0
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func initializeData(value: SearchValue, radioButtonCellRef: RadioButtonCell, index: Int) {
        data = value
        indexPath = index
        radioButtonCell = radioButtonCellRef
        buttonRadio.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }
    
    
    
    
    func initCellItem() {
        let deselectedImage = UIImage(named: "uncheck")?.withRenderingMode(.alwaysTemplate)
        let selectedImage = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
        buttonRadio.setImage(deselectedImage, for: .normal)
        buttonRadio.setImage(selectedImage, for: .selected)
        buttonRadio.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }

    @objc func radioButtonTapped(_ radioButton: UIButton) {
        if (radioButtonCell.dataArray[indexPath].isSelected) {
            buttonRadio.setBackgroundImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            
          //  data?.isSelected = false
            radioButtonCell.dataArray[indexPath].isSelected = false
            
        }
        else {
            buttonRadio.setBackgroundImage(#imageLiteral(resourceName: "check"), for: .normal)
           // data?.isSelected = true
            radioButtonCell.dataArray[indexPath].isSelected = true
        }
        
        for (i, value) in radioButtonCell.dataArray.enumerated() {
            if i != indexPath {
                radioButtonCell.dataArray[i].isSelected = false
            }
        }
        radioButtonCell.tableView.reloadData()
    }
    
//    @objc func radioButtonTapped(_ radioButton: UIButton) {
//        let isSelected = !self.buttonRadio.isSelected
//        self.buttonRadio.isSelected = isSelected
//        if isSelected {
//            deselectOtherButton()
//        }
//    }
//
    
    func deselectOtherButton() {
        let tableView = self.superview?.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        let section = tappedCellIndexPath.section
        let rowCounts = tableView.numberOfRows(inSection: section)
        
        for row in 0..<rowCounts {
            if row != tappedCellIndexPath.row {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as! RadioButtonTableViewCell
                cell.buttonRadio.isSelected = false
            }
        }
    }
}




