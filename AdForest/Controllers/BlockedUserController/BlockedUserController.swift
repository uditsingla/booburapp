//
//  BlockedUserController.swift
//  AdForest
//
//  Created by apple on 5/24/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BlockedUserController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    //MARK:- Properties
    var dataArray = [BlockedUsers]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
        self.adForest_getBlockedUsersList()
        self.googleAnalytics(controllerName: "Blocked Users Controller")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //Remove item at selected Index
    func removeItem(index: Int) {
        dataArray.remove(at: index)
        self.tableView.reloadData()
    }
    
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlockeduserCell = tableView.dequeueReusableCell(withIdentifier: "BlockeduserCell", for: indexPath) as! BlockeduserCell
        let objData = dataArray[indexPath.row]
        
        if let imgUrl = URL(string: objData.image) {
            cell.imgProfile.sd_setShowActivityIndicatorView(true)
            cell.imgProfile.sd_setIndicatorStyle(.gray)
            cell.imgProfile.sd_setImage(with: imgUrl, completed: nil)
        }
        
        if let name = objData.name {
            cell.lblName.text = name
        }
        
        if let location = objData.location {
            cell.lblLocation.text = location
        }
        if let buttonText = objData.text {
            cell.oltUnBlock.setTitle(buttonText, for: .normal)
        }
        
        cell.btnUnBlock = { () in
            var userID = ""
            if let id = objData.id {
                userID = id
            }
            let param: [String: Any] = ["user_id": userID]
            print(param)
            self.removeItem(index: indexPath.row)
            self.adForest_UnBlockUser(parameter: param as NSDictionary)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //MARK:- API Call
    
    func adForest_getBlockedUsersList() {
        self.showLoader()
        UserHandler.blockedUsersList(success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success{
                self.title = successResponse.data.pageTitle
                self.dataArray = successResponse.data.users
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
    
    //Un Block User
    func adForest_UnBlockUser(parameter: NSDictionary) {
        self.showLoader()
        UserHandler.unBlockUser(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
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
    
}


class BlockeduserCell: UITableViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var imgProfile: UIImageView!{
        didSet {
            imgProfile.round()
        }
    }
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var oltUnBlock: UIButton!
    
    //MARK:- Properties
    var btnUnBlock: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        backgroundColor = UIColor.groupTableViewBackground
    }
    
    @IBAction func actionUnBlock(_ sender: Any) {
        self.btnUnBlock?()
    }
    
}
