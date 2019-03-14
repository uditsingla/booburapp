//
//  SentOffersController.swift
//  AdForest
//
//  Created by apple on 3/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class SentOffersController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.addSubview(refreshControl)
            tableView.showsVerticalScrollIndicator = false
            let nib = UINib(nibName: "MessagesCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "MessagesCell")
        }
    }
    
    //MARK:- Properties
    var dataArray = [SentOffersItem]()
    var defaults = UserDefaults.standard
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(refreshTableView),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    
    //MARK:- View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateSentOffersData), object: nil, queue: nil) { (notification) in
            self.dataArray = UserHandler.sharedInstance.sentOffersArray
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
        tracker?.set(kGAIScreenName, value: "Sent Offers")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
   
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    @objc func refreshTableView() {
        self.dataArray = UserHandler.sharedInstance.sentOffersArray
        self.tableView.reloadData()
    }
    
    //MARK:- table View Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessagesCell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath) as! MessagesCell
        
        let objData = dataArray[indexPath.row]
        
        if let title = objData.messageAdTitle {
            cell.lblName.text = title
        }
        if let name = objData.messageAuthorName {
            cell.lblDetail.text = name
        }
        
        for item in objData.messageAdImg {
            if let imgUrl = URL(string: item.thumb) {
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objData = dataArray[indexPath.row]
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatController") as! ChatController
        chatVC.ad_id = objData.adId
        chatVC.sender_id = objData.messageSenderId
        chatVC.receiver_id = objData.messageReceiverId
        chatVC.messageType = "sent"
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
        
        let data = dataArray[indexPath.row]
        let objData = UserHandler.sharedInstance.objSentOffers
        
        var currentPage = objData?.pagination.currentPage
        let maximumPage = objData?.pagination.maxNumPages
        
        if indexPath.row == dataArray.count - 1 && currentPage! < maximumPage! {
            currentPage = currentPage! + 1
            let param: [String: Any] = ["page_number": currentPage!]
            self.adForest_loadMoreData(param: param as NSDictionary)
            self.showLoader()
        }
    }
    
    
    //MARK:- API Calls
    func adForest_loadMoreData(param: NSDictionary) {
        UserHandler.moreSentOffersData(param: param, success: { (successResponse) in
            self.stopAnimating()
            self.refreshControl.endRefreshing()
            if successResponse.success {
                self.dataArray.append(contentsOf: successResponse.data.sentOffers.items)
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

extension SentOffersController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
       
        var pagerStripTitle = ""
        if let settingsInfo = defaults.object(forKey: "settings") {
            let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
            print(settingObject)
            let model = SettingsRoot(fromDictionary: settingObject)
            print(model)
            if let pagerTitle = model.data.messagesScreen.sent {
                pagerStripTitle = pagerTitle
            }
        }
        
        let title = pagerStripTitle
        return IndicatorInfo(title: title)
    }
    
}
