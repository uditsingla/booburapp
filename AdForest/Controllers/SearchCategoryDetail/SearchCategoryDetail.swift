//
//  SearchCategoryDetail.swift
//  AdForest
//
//  Created by apple on 5/5/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
protocol SubCategoryDelegate {
    func subCategoryDetails(name: String, id: Int, hasSubType: Bool, hasTempelate: Bool, hasCatTempelate: Bool)
}

class SearchCategoryDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    //MARK:- Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .singleLine
            tableView.separatorColor = UIColor.lightGray
        }
    }
    @IBOutlet weak var oltSubmit: UIButton! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltSubmit.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var oltCancel: UIButton! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltCancel.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
        }
    }
}
   // @IBOutlet weak var cstTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewTopLabel: UIView!{
        didSet{
            viewTopLabel.layer.borderWidth = 0.3
            viewTopLabel.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    //MARK:- Properties
    var delegate: SubCategoryDelegate?
    var dataArray = [SubCategoryValue]()
    
    var hasCatTemp = false
    
    //MARK:- view Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adForest_populateData()
        self.googleAnalytics(controllerName: "Search Category Detail")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if AddsHandler.sharedInstance.objSearchCategory != nil {
            let data = AddsHandler.sharedInstance.objSearchCategory
            if let title = data?.title {
                self.lblName.text = title
            }
            if let hasCatTempelate = data?.hasCatTemplate{
                self.hasCatTemp = hasCatTempelate
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
        let cell: SearchCategoryDetailCell = tableView.dequeueReusableCell(withIdentifier: "SearchCategoryDetailCell", for: indexPath) as! SearchCategoryDetailCell
        let objdata = dataArray[indexPath.row]
        
        if let name = objdata.name {
            cell.lblName.text = name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData = dataArray[indexPath.row]
    
        self.dismissVC {
            self.delegate?.subCategoryDetails(name: objData.name, id: objData.id, hasSubType: objData.hasSub, hasTempelate: objData.hasTemplate, hasCatTempelate: self.hasCatTemp)
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func actionSubmit(_ sender: Any) {
        self.dismissVC(completion: nil)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        self.dismissVC(completion: nil)
    }
}

//MARK:- Cell Class
class SearchCategoryDetailCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}




