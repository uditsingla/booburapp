//
//  AddsTableCell.swift
//  AdForest
//
//  Created by apple on 4/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
protocol AddDetailDelegate{
    func goToAddDetail(ad_id : Int)
}
class AddsTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.clear
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    @IBOutlet weak var lblSectionTitle: UILabel!
    @IBOutlet weak var oltViewAll: UIButton! {
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltViewAll.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    
    //MARK:- Properties
    var dataArray = [HomeAdd]()
    var delegate : AddDetailDelegate?

    var btnViewAll :(()->())?
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    //MARK:- Custom
    
    func reloadData() {
        collectionView.reloadData()
    }
   
    //MARK:- Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:  AddsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddsCollectionCell", for: indexPath) as! AddsCollectionCell
        let objData = dataArray[indexPath.row]
        for images in objData.adImages {
            if let imgUrl = URL(string: images.thumb) {
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
    
    
    //MARK:- IBActions
    
    @IBAction func actionViewAll(_ sender: Any) {
        self.btnViewAll?()
    }
}
