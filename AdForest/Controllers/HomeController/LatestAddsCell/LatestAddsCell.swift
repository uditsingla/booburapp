//
//  LatestAddsCell.swift
//  AdForest
//
//  Created by Apple on 13/06/2018.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class LatestAddsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var oltViewAll: UIButton!{
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltViewAll.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    //MARK:- Properties
    var delegate : AddDetailDelegate?
    var dataArray = [HomeAdd]()
    var btnViewAll: (()->())?
    
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
        let cell: LatestAddsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestAddsCollectionCell", for: indexPath) as! LatestAddsCollectionCell
        let objData = dataArray[indexPath.row]
        
        for item in objData.adImages {
            if let imgUrl = URL(string: item.thumb) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
        }
        
        if let name = objData.adTitle {
            cell.lblName.text = name
        }
        if let location = objData.adLocation.address {
            cell.lblLocation.text = location
        }
        if let price = objData.adPrice.price {
            cell.lblPrice.text = price
        }
        cell.btnFullAction = { () in
            self.delegate?.goToAddDetail(ad_id: objData.adId)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    
    @IBAction func actionViewAll(_ sender: Any) {
        self.btnViewAll?()
    }
}


class LatestAddsCollectionCell : UICollectionViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel!{
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                lblPrice.textColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    //MARK:- Properties
    var btnFullAction : (()->())?
    
    //MARK:- IBActions
    @IBAction func actionFullButton(_ sender: Any) {
        self.btnFullAction?()
    }
}
