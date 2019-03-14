//
//  OffersOnAdsController.swift
//  AdForest
//
//  Created by apple on 3/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class OffersOnAdsController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView! {
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
    var defaults = UserDefaults.standard
    var dataArray = [OfferAdsItem]()
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
        self.showLoader()
        self.adForest_getOffersData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Offer on Ads")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    @objc func refreshTableView() {
        self.adForest_getOffersData()
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
        
        for item in objData.messageAdImg {
            if let imgUrl = URL(string: item.thumb) {
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
            }
        }
        if let name = objData.messageAdTitle {
            cell.lblName.text = name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objdata = dataArray[indexPath.row]
        let offerDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "OffersonAdsDetailController") as! OffersonAdsDetailController
        offerDetailVC.ad_id = objdata.adId
        self.navigationController?.pushViewController(offerDetailVC, animated: true)
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
    
        if indexPath.row == dataArray.count - 1 && currentPage < maximumPage {
            currentPage = currentPage + 1
            let param: [String: Any] = ["page_number": currentPage]
            print(param)
            self.adForest_moreOffersData(param: param as NSDictionary)
            self.showLoader()
        }
    }
    
    //MARK:- API Call
    func adForest_getOffersData() {
        UserHandler.offerOnAds(success: { (successResponse) in
            self.stopAnimating()
            self.refreshControl.endRefreshing()
            if successResponse.success {
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                UserHandler.sharedInstance.objOfferOnAdsData = successResponse.data
                self.dataArray = successResponse.data.receivedOffers.items
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
    
    // Load More Data
    func adForest_moreOffersData(param: NSDictionary) {
        UserHandler.moreOfferAdsData(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            self.refreshControl.endRefreshing()
            if successResponse.success {
                self.currentPage = successResponse.data.pagination.currentPage
                self.maximumPage = successResponse.data.pagination.maxNumPages
                UserHandler.sharedInstance.objOfferOnAdsData = successResponse.data
                self.dataArray.append(contentsOf: successResponse.data.receivedOffers.items)
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

extension OffersOnAdsController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        var pagerStripTitle = ""
        if let settingsInfo = defaults.object(forKey: "settings") {
            let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
            print(settingObject)
            let model = SettingsRoot(fromDictionary: settingObject)
            print(model)
            if let pagerTitle = model.data.messagesScreen.receive {
                pagerStripTitle = pagerTitle
            }
        }
        
        let title = pagerStripTitle
        return IndicatorInfo(title: title)
    }
}
