//
//  AdRatingCell.swift
//  AdForest
//
//  Created by apple on 4/11/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import Cosmos
import TextFieldEffects
import NVActivityIndicatorView

class AdRatingCell: UITableViewCell, NVActivityIndicatorViewable {

    //MARK:- Outlets
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ratingBar: CosmosView! {
        didSet {
            ratingBar.settings.updateOnTouch = true
            ratingBar.settings.fillMode = .full
        }
    }
    @IBOutlet weak var txtComment: HoshiTextField!
    @IBOutlet weak var lblNotEdit: UILabel!
    @IBOutlet weak var oltSubmitRating: UIButton!{
        didSet{
            if let mainColor = UserDefaults.standard.string(forKey: "mainColor"){
                oltSubmitRating.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var lblPostComment: UILabel!
    
    //MARK:- Properties
    
    var btnSubmitAction: (()->())?
    var rating: Double = 0
    var adID = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    //MARK:- IBActions
    @IBAction func actionSubmitRating(_ sender: Any) {
        self.btnSubmitAction?()
        guard let comment = txtComment.text else {
            return
        }
        
        if comment == "" {
            
        }
            
            
        else {
            let param: [String: Any] = ["ad_id": adID, "rating": rating, "rating_comments": comment]
            print(param)
            let addDetail = AddDetailController()
            addDetail.showLoader()
            AddsHandler.ratingToAdd(parameter: param as NSDictionary, success: { (successResponse) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                if successResponse.success {
                    let alert = Constants.showBasicAlert(message: successResponse.message)
                    self.appDelegate.presentController(ShowVC: alert)
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
    
    private func didTouchCosmos(_ rating: Double) {
        print("Start \(rating)")
        self.rating = rating
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
        print("End \(rating)")
        self.rating = rating
    }
}
