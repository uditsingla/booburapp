//
//  ChatController.swift
//  AdForest
//
//  Created by apple on 3/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var containerViewTop: UIView! {
        didSet {
            containerViewTop.addShadowToView()
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.addSubview(refreshControl)
        }
    }
    
    @IBOutlet weak var buttonSendMessage: UIButton!{
        didSet {
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor") {
                buttonSendMessage.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var imgMessage: UIImageView!
    
    @IBOutlet weak var containerViewBottom: UIView! {
        didSet {
            containerViewBottom.layer.borderWidth = 0.5
            containerViewBottom.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var txtMessage: UITextView!
    
    //MARK:- Properties
    var ad_id = ""
    var sender_id = ""
    var receiver_id = ""
    var messageType = ""
    
    var dataArray = [SentOfferChat]()
    var reverseArray = [SentOfferChat]()
    
    var currentPage = 0
    var maximumPage = 0
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(refreshTableView),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.showBackButton()
        self.refreshButton()
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Chat Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        
        
        let parameter : [String: Any] = ["ad_id": ad_id, "sender_id": sender_id, "receiver_id": receiver_id, "type": messageType, "message": ""]
        print(parameter)
        self.adForest_getChatData(parameter: parameter as NSDictionary)
        self.showLoader()
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.dataArray.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    @objc func refreshTableView() {
        let parameter : [String: Any] = ["ad_id": ad_id, "sender_id": sender_id, "receiver_id": receiver_id, "type": messageType, "message": ""]
        print(parameter)
        self.adForest_getChatData(parameter: parameter as NSDictionary)
    }
    
    func adForest_populateData() {
        if UserHandler.sharedInstance.objSentOfferChatData != nil {
            let objData = UserHandler.sharedInstance.objSentOfferChatData
           
            if let addtitle = objData?.adTitle {
                self.lblName.text =  addtitle
            }
            if let price = objData?.adPrice.price {
                self.lblPrice.text = price
            }
            if let date = objData?.adDate {
                self.lblDate.text = date
            }
            
        }
    }
    
    func refreshButton() {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(#imageLiteral(resourceName: "refresh"), for: .normal)
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
        let parameter : [String: Any] = ["ad_id": ad_id, "sender_id": sender_id, "receiver_id": receiver_id, "type": messageType, "message": ""]
        print(parameter)
        self.showLoader()
        self.adForest_getChatData(parameter: parameter as NSDictionary)
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
        if objData.type == "reply" {
            let cell: SenderCell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell

            if let message = objData.text {
                cell.txtMessage.text = message
            }
            if let imgUrl = URL(string: objData.img) {
                cell.imgProfile.sd_setIndicatorStyle(.gray)
                cell.imgProfile.sd_setShowActivityIndicatorView(true)
                cell.imgProfile.sd_setImage(with: imgUrl, completed: nil)
            }
            if let date = objData.date {
               // cell.text = date
            }
            return cell
        }
        else {
            let cell: ReceiverCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell

            if let message = objData.text {
               cell.txtMessage.text = message
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == dataArray.count - 1 && currentPage < maximumPage {
            currentPage = currentPage + 1
            let param: [String: Any] = ["page_number": currentPage]
            print(param)
            self.showLoader()
            self.adForest_loadMoreChat(parameter: param as NSDictionary)
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func actionSendMessage(_ sender: Any) {
    
        guard let messageField = txtMessage.text else {
            return
        }
        
        if messageField == "" {
            
        }
        else {
            let parameter : [String: Any] = ["ad_id": ad_id, "sender_id": sender_id, "receiver_id": receiver_id, "type": "", "message": messageField]
            print(parameter)
            self.adForest_sendMessage(param: parameter as NSDictionary)
            self.showLoader()
        }
    }
    
    //MARK:- API Call
    
    func adForest_getChatData(parameter: NSDictionary) {
        UserHandler.getSentOfferMessages(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            self.refreshControl.endRefreshing()
            if successResponse.success {
                self.title = successResponse.data.pageTitle
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                UserHandler.sharedInstance.objSentOfferChatData = successResponse.data
                self.reverseArray = successResponse.data.chat
                self.dataArray = self.reverseArray.reversed()
                self.adForest_populateData()
                self.tableView.reloadData()
                self.scrollToBottom()
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
    
    //Load More Chat
    func adForest_loadMoreChat(parameter: NSDictionary) {
        UserHandler.getSentOfferMessages(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            self.refreshControl.endRefreshing()
            print(successResponse)
            if successResponse.success {
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                UserHandler.sharedInstance.objSentOfferChatData = successResponse.data
                self.reverseArray = successResponse.data.chat
                self.dataArray.append(contentsOf: self.reverseArray.reversed())
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
    
    //send message
    func adForest_sendMessage(param: NSDictionary) {
        UserHandler.sendMessage(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            self.refreshControl.endRefreshing()
            if successResponse.success {
                self.txtMessage.text = ""
                UserHandler.sharedInstance.objSentOfferChatData = successResponse.data
                self.reverseArray = successResponse.data.chat
                self.dataArray = self.reverseArray.reversed()
                self.tableView.reloadData()
                self.scrollToBottom()
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


class SenderCell: UITableViewCell {
    

    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var imgProfile: UIImageView! {
        didSet {
            imgProfile.round()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}

class ReceiverCell: UITableViewCell {
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var txtMessage: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}

