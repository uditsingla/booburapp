//
//  AadPostController.swift
//  AdForest
//
//  Created by apple on 4/25/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AadPostController: UIViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.black
            tableView.showsVerticalScrollIndicator = false
        }
    }
    
    //MARK:- Properties
    var isFromEditAd = false
    var ad_id = 0
    var catID = ""
    var dataArray = [AdPostField]()
    var newArray = [AdPostField]()
    var imagesArray = [AdPostImageArray]()
    var dynamicArray = [AdPostField]()
    var hasPageNumber = ""
    var refreshArray = [AdPostField]()
    var imageIDArray = [Int]()
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.forwardButton()
        
        if isFromEditAd {
            let param: [String: Any] = ["is_update": ad_id]
            print(param)
            self.adForest_adPost(param: param as NSDictionary)
        }
        else {
            let param: [String: Any] = ["is_update": ""]
            print(param)
            self.adForest_adPost(param: param as NSDictionary)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Add Post Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
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
        var data = [AdPostField]()
        for index in  0..<dataArray.count {
            if let objData = dataArray[index] as? AdPostField {
                if objData.fieldType == "textfield"   {
        
                    if let cell  = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AdPostCell {
                        var obj = AdPostField()
//                        if cell.txtType.text == "" {
//                            let alert = Constants.showBasicAlert(message: "Title is Empty")
//                            self.presentVC(alert)
//                        }
//                        else {
                            obj.fieldVal = cell.txtType.text
                            obj.fieldTypeName = cell.fieldName
                            obj.fieldType = "textfield"
                            data.append(obj)
                        //}
                    }
                }
                else if objData.fieldType == "select"   {
                    
                    if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AdPostPopupCell {
                        var obj = AdPostField()
                        if cell.selectedKey == "" {
                            let alert = Constants.showBasicAlert(message: "Select Category")
                            self.presentVC(alert)
                        }
                        else {
                            obj.fieldVal = cell.selectedKey
                            obj.fieldTypeName = cell.fieldName
                            obj.fieldType = "select"
                            data.append(obj)
                        }
                    }
                }
            }
        }
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "AdPostImagesController") as! AdPostImagesController
        if AddsHandler.sharedInstance.isCategoeyTempelateOn {
            self.refreshArray = dataArray
            self.refreshArray.insert(contentsOf: AddsHandler.sharedInstance.objAdPostData, at: 2)
            postVC.fieldsArray = self.refreshArray
            postVC.objArray = data
            postVC.isfromEditAd = self.isFromEditAd
        }
        else {
            postVC.objArray = data
            postVC.fieldsArray = self.dataArray
            postVC.isfromEditAd = self.isFromEditAd
        }
        postVC.imageArray = self.imagesArray
        postVC.imageIDArray = self.imageIDArray
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasPageNumber == "1" {
            return dataArray.count
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objData = dataArray[indexPath.row]
        
        if objData.fieldType == "textfield"  && objData.hasPageNumber == "1" {
            let cell: AdPostCell = tableView.dequeueReusableCell(withIdentifier: "AdPostCell", for: indexPath) as! AdPostCell
        
            if let title = objData.title  {
                cell.txtType.placeholder = title
            }
            
            if let fieldValue = objData.fieldVal {
                cell.txtType.text = fieldValue
            }
            cell.fieldName = objData.fieldTypeName
    
            return cell
        }
         
        else if objData.fieldType == "select" && objData.hasPageNumber == "1"  {
            let cell: AdPostPopupCell = tableView.dequeueReusableCell(withIdentifier: "AdPostPopupCell", for: indexPath) as! AdPostPopupCell
            
            if let title = objData.title {
                cell.lblType.text = title
            }
            
            if let fieldValue = objData.fieldVal {
                cell.oltPopup.setTitle(fieldValue, for: .normal)
            }
            var i = 1
            for item in objData.values {
                if item.id == "" {
                    continue
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
                cell.hasCatTemplateArray = []
                cell.hasTempelateArray = []
                cell.hasSubArray = []
                for items in objData.values {
                    if items.id == "" {
                        continue
                    }
                    cell.dropDownKeysArray.append(String(items.id))
                    cell.dropDownValuesArray.append(items.name)
                    cell.hasCatTemplateArray.append(objData.hasCatTemplate)
                    cell.hasTempelateArray.append(items.hasTemplate)
                    cell.hasSubArray.append(items.hasSub)
                }
                cell.popupShow()
                cell.selectionDropdown.show()
            }
            cell.fieldName = objData.fieldTypeName
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let objData = dataArray[indexPath.row]
        if objData.fieldType == "textfield" {
            height = 60
        }
        else if objData.fieldType == "select" {
            height = 80
        }
        return height
    }
    
    //MARK:- API Calls
    func adForest_adPost(param: NSDictionary) {
        print(param)
        self.showLoader()
        AddsHandler.adPost(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                self.title = successResponse.data.title
                AddsHandler.sharedInstance.isCategoeyTempelateOn = successResponse.data.catTemplateOn
                //this ad id send in parameter in 3rd step
                AddsHandler.sharedInstance.adPostAdId = successResponse.data.adId
                AddsHandler.sharedInstance.objAdPost = successResponse
                //Fields
                self.dataArray = successResponse.data.fields
                self.newArray = successResponse.data.fields
                self.imagesArray = successResponse.data.adImages
                for imageId in self.imagesArray {
                    if imageId.imgId == nil {
                        continue
                    }
                    self.imageIDArray.append(imageId.imgId)
                }
                for item in successResponse.data.fields {
                    if item.hasPageNumber == "1" {
                        self.hasPageNumber = item.hasPageNumber
                    }
                }
                
                //get category id to get dynamic fields
                if let cat_id = successResponse.data.adCatId {
                    self.catID = String(cat_id)
                }
                
                if successResponse.data.adCatId != nil {
                    let param: [String: Any] = ["cat_id": self.catID,
                                                "ad_id": self.ad_id
                                                ]
                    print(param)
                    self.adForest_dynamicFields(param: param as NSDictionary)
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
    
    // Dynamic Fields
    func adForest_dynamicFields(param: NSDictionary) {
       self.showLoader()
        AddsHandler.adPostDynamicFields(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                AddsHandler.sharedInstance.objAdPostData = successResponse.data.fields
                AddsHandler.sharedInstance.adPostImagesArray = successResponse.data.adImages
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
