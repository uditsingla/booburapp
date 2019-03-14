//
//  CategoriesTableCell.swift
//  AdForest
//
//  Created by apple on 4/17/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

protocol CategoryDetailDelegate {
    func goToCategoryDetail(id: Int)
}

class CategoriesTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.isScrollEnabled = false
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    
    //MARK:- Properties
    var categoryArray = [CatIcon]()
    var delegate : CategoryDetailDelegate?
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

    }

    //MARK:- Collection View Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoriesCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollectionCell", for: indexPath) as! CategoriesCollectionCell
        
        let objData = categoryArray[indexPath.row]
        
        if let name = objData.name {
            cell.lblName.text = name
        }
        if let imgUrl = URL(string: objData.img) {
            cell.imgPicture.sd_setShowActivityIndicatorView(true)
            cell.imgPicture.sd_setIndicatorStyle(.gray)
            cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.goToCategoryDetail(id: categoryArray[indexPath.row].catId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if Constants.isiPadDevice {
            let padding: CGFloat =  50
            let collectionViewSize = collectionView.frame.size.width - padding
            return CGSize(width: collectionViewSize/4, height: collectionViewSize/4)
         
        }
        else {
            let itemWidth = CollectionViewSettings.getItemWidth(boundWidth: collectionView.bounds.size.width)
            return CGSize(width: itemWidth, height: itemWidth + 10)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
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
}
