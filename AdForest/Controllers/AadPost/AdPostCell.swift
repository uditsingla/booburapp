//
//  AdPostCell.swift
//  AdForest
//
//  Created by apple on 4/25/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import TextFieldEffects
import DropDown
import NVActivityIndicatorView

class AdPostCell: UITableViewCell {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var txtType: HoshiTextField!
    
     //MARK:- Properties
    var fieldName = ""
    var dataArray = [AdPostField]()
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
       selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class AdPostPopupCell : UITableViewCell, NVActivityIndicatorViewable, SubCategoryDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var oltPopup: UIButton! {
        didSet{
            oltPopup.contentHorizontalAlignment = .left
            oltPopup.setTitleColor(UIColor.darkGray, for: .normal)
        }
    }
    
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    
     //MARK:- Properties
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let selectionDropdown = DropDown()
    lazy var dropDowns : [DropDown] = {
        return [
            self.selectionDropdown
        ]
    }()
    var dropDownKeysArray = [String]()
    var dropDownValuesArray = [String]()
    var hasCatTemplateArray = [Bool]()
    var hasTempelateArray = [Bool]()
    var hasSubArray = [Bool]()
    var btnPopUpAction: (()->())?
    var selectedValue = ""
    var selectedKey = ""
    var fieldName = ""
    
    var hasCatTempelate = false
    var hasTempelate = false
    var hasSub = false
    
    var dataArray = [AdPostField]()
    var appDel = UIApplication.shared.delegate as! AppDelegate
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    //MARK:- SetUp Drop Down
    func popupShow() {
        selectionDropdown.anchorView = oltPopup
        selectionDropdown.dataSource = dropDownValuesArray
        selectionDropdown.selectionAction = { [unowned self]
            (index, item) in
            self.oltPopup.setTitle(item, for: .normal)
            self.selectedValue = item
            self.selectedKey = self.dropDownKeysArray[index]
            self.hasTempelate = self.hasTempelateArray[index]
            self.hasCatTempelate = self.hasCatTemplateArray[index]
            self.hasSub = self.hasSubArray[index]
          
            if self.hasCatTempelate {
                if self.hasTempelate {
                    let param: [String: Any] = ["cat_id": self.selectedKey]
                    print(param)
                    self.adForest_dynamicFields(param: param as NSDictionary)
                }
            }
            
            if self.hasSub {
                let param: [String: Any] = ["subcat": self.selectedKey]
                print(param)
                self.adForest_subCategoryData(param: param as NSDictionary)
            }
        }
    }
    
    //MARK:- Delegate Function
    func subCategoryDetails(name: String, id: Int, hasSubType: Bool, hasTempelate: Bool, hasCatTempelate: Bool) {
        print(name, id, hasSubType, hasTempelate, hasCatTempelate)
        if hasSubType {
            let param: [String: Any] = ["subcat": id]
            print(param)
            self.adForest_subCategoryData(param: param as NSDictionary)
        }
        else {
            self.oltPopup.setTitle(name, for: .normal)
            self.selectedKey = String(id)
            self.selectedValue = name
        }
        if hasCatTempelate {
            if hasTempelate {
                let param: [String: Any] = ["cat_id" : id]
                print(param)
                self.adForest_dynamicFields(param: param as NSDictionary)
            }
        }
    }
    
     //MARK:- IBActions
    
    @IBAction func actionPopup(_ sender: Any) {
        self.btnPopUpAction?()
    }

    //MARK:- API Call
    
    func adForest_dynamicFields(param: NSDictionary) {
        let adPostVC = AadPostController()
        adPostVC.showLoader()
        AddsHandler.adPostDynamicFields(parameter: param, success: { (successResponse) in
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if successResponse.success {
            AddsHandler.sharedInstance.objAdPostData = successResponse.data.fields
            AddsHandler.sharedInstance.adPostImagesArray = successResponse.data.adImages

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
    
    // Sub category data
    func adForest_subCategoryData(param: NSDictionary) {
        let adPostVC = AadPostController()
        adPostVC.showLoader()
        AddsHandler.adPostSubcategory(parameter: param, success: { (successResponse) in
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
}
