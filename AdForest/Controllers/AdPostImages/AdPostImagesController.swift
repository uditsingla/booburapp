//
//  AdPostImagesController.swift
//  AdForest
//
//  Created by apple on 4/26/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import RichEditorView
import Photos
import NVActivityIndicatorView
import Alamofire
import OpalImagePicker


class AdPostImagesController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, OpalImagePickerControllerDelegate, UINavigationControllerDelegate , AddDataDelegate {
   
   
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //MARK:- Properties
    var photoArray = [UIImage]()
   
    var imageArray = [AdPostImageArray]()
    
    var fieldsArray = [AdPostField]()
    var data = [AdPostImageArray]()
    var adID = 0
    var imageIDArray = [Int]()
    //this array get data from previous controller
    var objArray = [AdPostField]()
    var customArray = [AdPostField]()
    var haspageNumber = ""
    var localArray = AddsHandler.sharedInstance.objAdPostData
    var dataArray = [AdPostField]()
    var valueArray = [String]()
    var maximumImagesAllowed = 0
    var localVariable = ""
    var localDictionary = [String: Any]()
    var isfromEditAd = false
    let defaults = UserDefaults.standard
    
    var isFromAddData = ""
    var popUpTitle = ""
    var selectedIndex = 0
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.hideKeyboard()
        self.forwardButton()
        self.adForest_populateData()
    
        for ite in objArray {
            print(ite.fieldTypeName, ite.fieldName, ite.fieldVal, ite.fieldType)
        }
        self.dataArray = fieldsArray
        
        let valuesArray = ["ad_title","ad_cats1" ,"ad_price_type", "ad_price", "ad_currency", "ad_condition", "ad_warranty", "ad_type", "ad_yvideo", "checkbox"]
        let valueToremove = ["ad_title","ad_cats1"]
        
        for item in dataArray {
            if AddsHandler.sharedInstance.isCategoeyTempelateOn ==  false {
                if valuesArray.contains(item.fieldTypeName) {
                    let value = item.fieldTypeName
                    let index = dataArray.index{ $0.fieldTypeName ==  value}
                    if let index = index {
                        dataArray.remove(at: index)
                    }
                }
            }
            else {
                if valueToremove.contains(item.fieldTypeName) {
                    let value = item.fieldTypeName
                    let index = dataArray.index{ $0.fieldTypeName ==  value}
                    if let index = index {
                        dataArray.remove(at: index)
                    }
                }
            }
        }
        fieldsArray = dataArray
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    
    
    func forwardButton() {
        let button = UIButton(type: .custom)
        if #available(iOS 11, *) {
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        else {
            button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        }
        button.setBackgroundImage(#imageLiteral(resourceName: "forwardButton"), for: .normal)
        button.addTarget(self, action: #selector(onForwardButtonClciked), for: .touchUpInside)
        
        let forwardBarButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = forwardBarButton
    }
    
    @objc func onForwardButtonClciked() {
        localVariable = ""
        for index in  0..<fieldsArray.count {
            if let objData = fieldsArray[index] as? AdPostField {
             
                if objData.fieldType == "select"  {
    
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? DropDownCell {
                      
                        var obj = AdPostField()
                        if cell.selectedKey == "" {
                            let alert = Constants.showBasicAlert(message: "Select Categories")
                            self.presentVC(alert)
                        }
                        else {
                            obj.fieldType = "select"
                            obj.fieldTypeName = cell.param
                            print(cell.param)
                            obj.fieldVal = cell.selectedKey
                            objArray.append(obj)
                            customArray.append(obj)
                        }
                    }
                }
                else if objData.fieldType == "textfield"  {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? TextFieldCell {
                        var obj = AdPostField()
                        if cell.txtType.text == "" {
                            let alert = Constants.showBasicAlert(message: "Write Something")
                            self.presentVC(alert)
                        }
                        else {
                            obj.fieldType = "textfield"
                            obj.fieldVal = cell.txtType.text
                            obj.fieldTypeName = cell.fieldName
                            objArray.append(obj)
                            customArray.append(obj)
                        }
                    }
                }
                else if objData.fieldType == "textarea" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? DescriptionTableCell {
                         var obj = AdPostField()
                        
                        obj.fieldType = "textarea"
                        obj.fieldVal = cell.richEditorView.html
                        obj.fieldTypeName = cell.fieldName
                        objArray.append(obj)
                        customArray.append(obj)
                    }
                }
                
                else if objData.fieldType == "checkbox" {
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 2)) as? CheckBoxCell {
                        
                        var obj = AdPostField()
                        
                        obj.fieldTypeName = cell.fieldName
                        objArray.append(obj)
                        customArray.append(obj)

                        localVariable = ""
                        for item in cell.valueArray {
                            localVariable += item + ","
                        }
                        self.localDictionary[cell.fieldName] = localVariable
                    }
                }
            }
        }
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AdPostMapController") as! AdPostMapController
        if imageIDArray.isEmpty {
            let alert = Constants.showBasicAlert(message: "Images Required")
            self.presentVC(alert)
        }
        else {
            adPostVC.imageIdArray = imageIDArray
            adPostVC.objArray = objArray
            adPostVC.customArray = self.customArray
            adPostVC.localVariable = self.localVariable
            adPostVC.valueArray = self.valueArray
            adPostVC.localDictionary = self.localDictionary
            self.navigationController?.pushViewController(adPostVC, animated: true)
        }
    }
    
    func adForest_populateData() {
        if  AddsHandler.sharedInstance.objAdPost != nil {
            let objData = AddsHandler.sharedInstance.objAdPost
            if let titleText = objData?.data.title {
                self.title = titleText
            }
            if let id = objData?.data.adId {
                self.adID = id
            }
            if let maximumImages = objData?.data.images.numbers {
                self.maximumImagesAllowed = maximumImages
            }
        }
    }
    
    
    //MARK:- Add Data Delegate
    
    func addToFieldsArray(obj: AdPostField, index: Int) {
        fieldsArray.insert(obj, at: index)
        self.tableView.reloadData()
    }
   
    func addToFieldsArray(obj: AdPostField, index: Int, isFrom: String, title: String) {
        if isFrom == "textfield" {
            fieldsArray.insert(obj, at: index)
            self.tableView.reloadData()
        }
        else if isFrom == "select" {
            self.selectedIndex = index
            fieldsArray.insert(obj, at: index)
        }
    }
    
    
    //MARK:- table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        if section == 0 {
            returnValue =  1
        }
        else if section == 1 {
              returnValue =  1
        }
        else if section == 2 {
            returnValue = fieldsArray.count
        }
      return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if section == 0 {
            let cell: UploadImageCell = tableView.dequeueReusableCell(withIdentifier: "UploadImageCell", for: indexPath) as! UploadImageCell
            
            let objData = AddsHandler.sharedInstance.objAdPost
        
            if let imagesTitle = objData?.extra.imageText {
                cell.lblSelectImages.text = imagesTitle
            }
            
            cell.lblPicNumber.text = String(photoArray.count)
          
            cell.btnUploadImage = { () in
                let imagePicker = OpalImagePickerController()
                imagePicker.maximumSelectionsAllowed = self.maximumImagesAllowed
                print(self.maximumImagesAllowed)
                imagePicker.allowedMediaTypes = Set([PHAssetMediaType.image])
                // maximum message
                let configuration = OpalImagePickerConfiguration()
                configuration.maximumSelectionsAllowedMessage = NSLocalizedString((objData?.data.images.message)!, comment: "")
                imagePicker.configuration = configuration
                imagePicker.imagePickerDelegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
            return cell
        }
            
        else if section == 1 {
            let cell: CollectionImageCell = tableView.dequeueReusableCell(withIdentifier: "CollectionImageCell", for: indexPath) as! CollectionImageCell
             let objData = AddsHandler.sharedInstance.objAdPost
           
            if let sortMsg = objData?.extra.sortImageMsg {
                cell.lblArrangeImage.text = sortMsg
            }
            if let adID = objData?.data.adId {
                cell.ad_id = adID
            }
            cell.dataArray = self.imageArray
            cell.collectionView.reloadData()
            return cell
        }
            
        else if section == 2 {
            let objData = fieldsArray[indexPath.row]
       
            if objData.fieldType == "textfield"  {
                let cell: TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                
                if let title = objData.title {
                    cell.txtType.placeholder = title
                }
                if let value = objData.fieldVal {
                    cell.txtType.text = value
                }
                cell.fieldName = objData.fieldTypeName
                cell.selectedIndex = indexPath.row
                cell.delegate = self
                return cell
            }
                
            else if objData.fieldType == "select"  {
                let cell: DropDownCell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell

                if let title = objData.title {
                    cell.lblName.text = title
                }
                var i = 1
                for item in objData.values {
                    if item.id == "" {
                        continue
                    }
                    if (defaults.string(forKey: "value") != nil) {
                        if indexPath.row == selectedIndex {
                            let name = UserDefaults.standard.string(forKey: "value")
                            cell.oltPopup.setTitle(name, for: .normal)
                        }
                    }
                    if i == 1 {
                        cell.oltPopup.setTitle(item.name, for: .normal)
                        cell.selectedKey = String(item.id)
                    }
                    i = i + 1
                }
                cell.btnPopUpAction = { () in
                    cell.dropDownKeysArray = []
                    cell.dropDownValuesArray = []
                    cell.fieldTypeNameArray = []
                    for item in objData.values {
                        if item.id == "" {
                            continue
                        }
                        cell.dropDownKeysArray.append(String(item.id))
                        cell.dropDownValuesArray.append(item.name)
                        cell.fieldTypeNameArray.append(objData.fieldTypeName)
                    }
                    cell.accountDropDown()
                    cell.valueDropDown.show()
                }
                cell.param = objData.fieldTypeName
                cell.selectedIndex = indexPath.row
                cell.delegate = self
                return cell
            }
            
            else if objData.fieldType == "textarea" && objData.hasPageNumber == "2"  {
                let cell: DescriptionTableCell = tableView.dequeueReusableCell(withIdentifier: "DescriptionTableCell", for: indexPath) as! DescriptionTableCell
                
                if let title = objData.title {
                    cell.lblDescription.text = title
                }
                if let value = objData.fieldVal {
                    cell.richEditorView.html = value
                }
                cell.fieldName = objData.fieldTypeName
                
                return cell
            }
            else if objData.fieldType == "checkbox" {
                let cell: CheckBoxCell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxCell", for: indexPath) as! CheckBoxCell
                
                if let title = objData.title {
                    cell.lblName.text = title
                }
                cell.dataArray = objData.values
                cell.fieldName = objData.fieldTypeName
                cell.fieldType = objData.fieldType
                cell.tableView.reloadData()
                return cell
            }
        }
        return UITableViewCell()
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
       
        var height : CGFloat = 0
        if section == 0 {
            height = 100
        }
        else if section == 1 {
            if imageArray.isEmpty {
                height = 0
            }
            else {
                  height = 140
            }
        }
            
        else if section == 2 {
            let objData = fieldsArray[indexPath.row]
            if objData.fieldType == "textarea" {
                height = 250
            }
            else if objData.fieldType == "select" {
                height = 80
            }
            else if objData.fieldType == "textfield" {
                height = 80
            }
            else if objData.fieldType == "checkbox" {
                height = 230
            }
        }
        return height
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        
        if images.isEmpty {
        }
        else {
            self.photoArray = images
            let param: [String: Any] = [ "ad_id": String(adID)]
            print(param)
            self.adForest_uploadImages(param: param as NSDictionary, images: self.photoArray)
        }
            presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        self.dismissVC(completion: nil)
    }
    
    //MARK:- API Call
    
    //post images
    
    func adForest_uploadImages(param: NSDictionary, images: [UIImage]) {
        self.showLoader()
        AddsHandler.adPostUploadImages(parameter: param, imagesArray: images, fileName: "File", uploadProgress: { (uploadProgress) in
        }, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.imageArray = successResponse.data.adImages
                //add image id to array to send to next View Controller and hit to server
                for item in self.imageArray {
                    self.imageIDArray.append(item.imgId)
                }
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
