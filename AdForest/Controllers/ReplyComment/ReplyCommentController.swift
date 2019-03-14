//
//  ReplyCommentController.swift
//  AdForest
//
//  Created by apple on 3/16/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import TextFieldEffects

class ReplyCommentController: UIViewController , NVActivityIndicatorViewable{

    //MARK:- Outlets
    
    @IBOutlet weak var viewMsg: UIView! {
        didSet {
            viewMsg.circularView()
        }
    }
    @IBOutlet weak var imgMessage: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewCall: UIView!
    @IBOutlet weak var containerViewTxtField: UIView!
    @IBOutlet weak var txtComment: HoshiTextField!
    @IBOutlet weak var buttonCancel: UIButton!{
        didSet{
            if let mainColor = defaults.string(forKey: "mainColor"){
                buttonCancel.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    @IBOutlet weak var buttonOK: UIButton!{
        didSet {
            if let mainColor = defaults.string(forKey: "mainColor"){
                buttonOK.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
            }
        }
    }
    
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblNumber: UILabel! {
        didSet {
            lblNumber.layer.borderWidth = 1
            lblNumber.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var lblVerificationText: UILabel!
    
    //MARK:- Properties
    
    var isFromReplyComment = false
    var isFromMsg = false
    var isFromCall = false
    var isFromAddDetailReply = false
    var objAddDetail: AddDetailReplyDialogue?
    var objAddDetailData: AddDetailData?
    var objBlog : BlogDetailRoot?
    let defaults = UserDefaults.standard
    var ad_id = 0
    var comment_id = ""
    var phoneNumber = ""
    
    var post_id = 0
    
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Reply Comment Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        self.checkComingSide()
    }
    

    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func checkComingSide() {
        
        if isFromReplyComment {
            containerViewCall.isHidden = true
            containerViewTxtField.isHidden = false
            
            if objBlog != nil {
                let objData = objBlog
                if let postID = objData?.data.post.postId {
                    self.post_id = postID
                }
                
                if let commentButtonText = objData?.extra.commentForm.btnSubmit {
                    self.buttonOK.setTitle(commentButtonText, for: .normal)
                }
                if let cancelButtonText = objData?.extra.commentForm.btnCancel {
                    self.buttonCancel.setTitle(cancelButtonText, for: .normal)
                }
                if let txtPlaceHolder = objData?.extra.commentForm.textarea {
                    self.txtComment.placeholder = txtPlaceHolder
                }
            }
        }
        else if isFromMsg {
            if objAddDetailData != nil {
                let dataToShow = objAddDetailData
               
                containerViewCall.isHidden = true
                containerViewTxtField.isHidden = false
               
                if let adId = dataToShow?.adDetail.adId {
                    self.ad_id = adId
                }
                
                if let placeHoderText =  dataToShow?.messagePopup.inputTextarea {
                    txtComment.placeholder = placeHoderText
                }
                if let sendButtonText = dataToShow?.messagePopup.btnSend {
                    buttonOK.setTitle(sendButtonText, for: .normal)
                }
                if let cancelText = dataToShow?.messagePopup.btnCancel {
                    buttonCancel.setTitle(cancelText, for: .normal)
                }
            }
        }
            
        else if isFromCall {
            if objAddDetailData != nil {
                let dataToShow = objAddDetailData
                containerViewTxtField.isHidden = true
                containerViewCall.isHidden = false
                self.imgPic.image = #imageLiteral(resourceName: "Phone")
                
                if let buttonOkText = dataToShow?.callNowPopup.btnSend {
                    self.buttonOK.setTitle(buttonOkText, for: .normal)
                }
                if let buttonCancelText = dataToShow?.callNowPopup.btnCancel {
                    self.buttonCancel.setTitle(buttonCancelText, for: .normal)
                }
                
                if (dataToShow?.callNowPopup.phoneVerification)! {
                    if let number = dataToShow?.adDetail.phone {
                        self.lblNumber.text = number
                        self.phoneNumber = number
                    }
                    if let text = dataToShow?.callNowPopup.isPhoneVerifiedText {
                        self.lblVerificationText.text = text
                    }
                    
                    if (dataToShow?.callNowPopup.isPhoneVerified)! {
                         self.lblVerificationText.backgroundColor = Constants.hexStringToUIColor(hex: "#24a740")
                    }
                    else {
                          self.lblVerificationText.backgroundColor = Constants.hexStringToUIColor(hex: "#F25E5E")
                    }
                }
            }
        }
            
        else if isFromAddDetailReply {
            containerViewCall.isHidden = true
            containerViewTxtField.isHidden = false
            if objAddDetail != nil {
            let dataToShow = objAddDetail
                if let txtPlaceHolder = dataToShow?.text {
                    self.txtComment.placeholder = txtPlaceHolder
                }
                if let submitText = dataToShow?.sendBtn {
                    self.buttonOK.setTitle(submitText, for: .normal)
                }
                if let cancelText = dataToShow?.cancelBtn {
                    self.buttonCancel.setTitle(cancelText, for: .normal)
                }
            }
            else {
                print("No Data")
            }
        }
    }
    
    
    @IBAction func actionBigButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionOK(_ sender: UIButton) {
       
        guard let commentField = txtComment.text else {
            return
        }
        
        if isFromMsg {
            if commentField == "" {
                
            }
            else  {
                let param: [String: Any] = ["ad_id": ad_id, "message": commentField]
                print(param)
                self.adForest_popUpMessageReply(param: param as NSDictionary)
            }
            
        }
        
        else if isFromAddDetailReply {
            if commentField == "" {
                
            }
            else {
                let param: [String: Any] = ["ad_id": ad_id, "comment_id": comment_id, "rating_comments": commentField]
                print(param)
                self.adForest_replyComment(param: param as NSDictionary)
            }
        }
        else if isFromCall {
            print("Call \(phoneNumber)")
            phoneNumber.makeAColl()
        }
        else if isFromReplyComment {
            
            if commentField == "" {
                
            }
            else {
                let param: [String: Any] = ["comment_id": comment_id, "post_id": post_id, "message": commentField]
                print(param)
                self.adForest_blogPostComment(param: param as NSDictionary)
            }
        }
    }
    
    
    @IBAction func actionCancel(_ sender: UIButton) {
          dismiss(animated: true, completion: nil)
    }
    
    //MARK:- API Call
    //comment
    func adForest_replyComment(param: NSDictionary) {
        self.showLoader()
        AddsHandler.replyComment(parameters: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationName.updateAddDetails), object: nil)
                    self.dismiss(animated: true, completion: nil)
                })
                self.presentVC(alert)
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
    
    // pop up message reply
    func adForest_popUpMessageReply(param: NSDictionary) {
        self.showLoader()
        AddsHandler.popMsgReply(param: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
               
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.dismissVC(completion: nil)
                })
                self.presentVC(alert)
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
    
    // blog post comment
    func adForest_blogPostComment(param: NSDictionary) {
        self.showLoader()
        UserHandler.blogPostComment(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = AlertView.prepare(title: "", message: successResponse.message, okAction: {
                    self.dismissVC(completion: nil)
                })
                self.presentVC(alert)
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
