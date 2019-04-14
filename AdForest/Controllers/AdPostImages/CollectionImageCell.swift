//
//  CollectionImageCell.swift
//  AdForest
//
//  Created by apple on 4/26/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class CollectionImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, NVActivityIndicatorViewable {

    //MARK:- Properties
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    @IBOutlet weak var viewDragImage: UIView!
    @IBOutlet weak var lblArrangeImage: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    //MARK:- Properties
    var dataArray = [AdPostImageArray]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ad_id = 0
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK:- Collection View Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImagesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCell", for: indexPath) as! ImagesCell
        
        let objData = dataArray[indexPath.row]
        
        if let imgUrl = URL(string: objData.thumb ){
            cell.imgPictures.sd_setShowActivityIndicatorView(true)
            cell.imgPictures.sd_setIndicatorStyle(.gray)
            cell.imgPictures.sd_setImage(with: imgUrl, completed: nil)
        }
        cell.btnDelete = { () in
            let param: [String: Any] = ["ad_id": self.ad_id, "img_id": objData.imgId]
            print(param)
            self.removeItem(index: indexPath.row)
            self.adForest_deleteImage(param: param as NSDictionary)
        }
        return cell
    }
    
    //Remove item at selected Index
    func removeItem(index: Int) {
        dataArray.remove(at: index)
        self.collectionView.reloadData()
    }
    
    
    //MARK:- API Call
    func adForest_deleteImage(param: NSDictionary) {
        let mainClass = AdPostImagesController()
        mainClass.showLoader()
        AddsHandler.adPostDeleteImages(param: param, success: { (successResponse) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.appDelegate.presentController(ShowVC: alert)
               // NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.adPostImageDelete), object: nil, userInfo: nil)
            }
            else {
                let alert = Constants.showBasicAlert(message: successResponse.message)
                self.appDelegate.presentController(ShowVC: alert)
            }
            
        }) { (error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            let alert = Constants.showBasicAlert(message: error.message)
            self.appDelegate.presentController(ShowVC: alert)
        }
    }
}



class ImagesCell: UICollectionViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var imgPictures: UIImageView!
    @IBOutlet weak var containerViewCross: UIView!
    @IBOutlet weak var imgDelete: UIImageView!
    
    
    //MARK:- Properties
    var btnDelete: (()->())?
    
    //MARK:- IBActions
    @IBAction func actionDelete(_ sender: Any) {
        self.btnDelete?()
        print("Delete pressed")
    }
}
