//
//  AddDetailDescriptionCell.swift
//  AdForest
//
//  Created by apple on 4/10/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class AddDetailDescriptionCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var lblHtmlText: UILabel!
    @IBOutlet weak var lblTagTitle: UILabel!
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationValue: UILabel!
    
   // @IBOutlet weak var lblTagValue: UILabel!
    
    @IBOutlet weak var cstCollectionHeight: NSLayoutConstraint!
    
    
    //MARK:- Properties
    var fieldsArray = [AddDetailFieldsData]()
    
    
    //MARK:- View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cstCollectionHeight.constant = self.collectionView.contentSize.height
        collectionView.reloadData()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cstCollectionHeight.constant = self.collectionView.contentSize.height
    }
    
    //MARK:- Custom
    
    func adForest_reload() {
        cstCollectionHeight.constant = self.collectionView.contentSize.height
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    //MARK:- Collection View Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fieldsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AddDetailDescriptionCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddDetailDescriptionCollectionCell", for: indexPath) as! AddDetailDescriptionCollectionCell
        
        let objData = fieldsArray[indexPath.row]
        if let category = objData.key {
            cell.lblCategory.text = "\(category) :"
        }
        if let name = objData.value {
            cell.lblDescription.text = name
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width - 20 , height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


class AddDetailDescriptionCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
}
