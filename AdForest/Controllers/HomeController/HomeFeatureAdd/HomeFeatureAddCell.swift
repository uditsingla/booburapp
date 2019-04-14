//
//  HomeFeatureAddCell.swift
//  AdForest
//
//  Created by apple on 5/30/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit


class HomeFeatureAddCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    //MARK:- Properties
    var delegate: AddDetailDelegate?
    var dataArray = [HomeAdd]()
    
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.startTimer()
    }
    
    //MARK:- Custom
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
    }
  
    @objc func scrollToNextCell() {
        let cellSize = CGSize(width: frame.width, height: frame.height)
        let contentOffset = collectionView.contentOffset
        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
    }
    
    //MARK:- Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:  HomeFeatureCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFeatureCollectionCell", for: indexPath) as! HomeFeatureCollectionCell
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
        
        if let featurText = objData.adStatus.featuredTypeText {
            cell.lblFeatured.text = featurText
            cell.lblFeatured.backgroundColor = Constants.hexStringToUIColor(hex: "#E52D27")
        }
        cell.btnFullAction = { () in
            self.delegate?.goToAddDetail(ad_id: objData.adId)
        }
    
        return cell
    }
 
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
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
    
}
