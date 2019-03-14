//
//  BlogDetailController.swift
//  AdForest
//
//  Created by apple on 3/13/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BlogDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, UIWebViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            
            let nib = UINib(nibName: "BlogDetailCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "BlogDetailCell")
            let nibWebView = UINib(nibName: "WebViewCell", bundle: nil)
            tableView.register(nibWebView, forCellReuseIdentifier: "WebViewCell")
            
            let replyNib = UINib(nibName: "ReplyCell", bundle: nil)
            tableView.register(replyNib, forCellReuseIdentifier: "ReplyCell")
            let commentNib = UINib(nibName: "CommentCell", bundle: nil)
            tableView.register(commentNib, forCellReuseIdentifier: "CommentCell")
            
            let ratingNib = UINib(nibName: "AdRatingCell", bundle: nil)
            tableView.register(ratingNib, forCellReuseIdentifier: "AdRatingCell")
        }
    }
    
    @IBOutlet weak var oltAdPost: UIButton!{
        didSet {
            oltAdPost.circularButton()
            if let bgColor = defaults.string(forKey: "mainColor") {
                oltAdPost.backgroundColor = Constants.hexStringToUIColor(hex: bgColor)
            }
        }
    }
    
    //MARK:- Properties
    var post_id = 0
    let defaults = UserDefaults.standard
    var dataArray = [BlogDetailData]()
    var commentArray = [BlogDetailComment]()
    var replyArray = [BlogDetailReply]()
    var contentHeight : [CGFloat] = [0.0, 0.0]
    var webViewHeight: CGFloat = 0.0
  
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showBackButton()
    
        let param: [String: Any] = ["post_id": post_id]
        print(param)
        self.adForest_blogDetail(parameter: param as NSDictionary)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Blog Detail Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
    }
    
    //MARK: - Custom
    func showLoader(){
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 2 {
            if commentArray.isEmpty {
                return 0
            }
            else {
                return commentArray.count
            }
        }
        else if section == 3 {
            if replyArray.isEmpty {
                return  0
            }
            else {
                return replyArray.count
            }
        }
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell: BlogDetailCell = tableView.dequeueReusableCell(withIdentifier: "BlogDetailCell", for: indexPath) as! BlogDetailCell
            let objData = dataArray[indexPath.row]
            if objData.post.hasImage {
                if let imgUrl = URL(string: objData.post.image) {
                    cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
                    cell.imgPicture.sd_setShowActivityIndicatorView(true)
                    cell.imgPicture.sd_setIndicatorStyle(.gray)
                }
            }
            else if objData.post.hasImage == false {
                cell.imgPicture.isHidden = true
            }
            if let name = objData.post.title {
                cell.lblName.text = name
            }
            if let authorName = objData.post.authorName {
                cell.lblTitle.text = authorName
            }
            if let comments = objData.post.commentCount {
                cell.lblLikes.text = comments
            }
            if let date = objData.post.date {
                cell.lblDate.text = date
            }
            return cell
        }
        else if section == 1 {
            let cell: WebViewCell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
            let objData = dataArray[indexPath.row]
            let htmlString = objData.post.desc
            let htmlHeight = contentHeight[indexPath.row]

            cell.webView.tag = indexPath.row
            cell.webView.delegate = self
            cell.webView.loadHTMLString(htmlString!, baseURL: nil)
            cell.webView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: htmlHeight)
            return cell
        }
        else if section == 2 {
            let cell: ReplyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell
            let objData = commentArray[indexPath.row]
            if let imgUrl = URL(string: objData.img) {
                cell.imgProfile.sd_setShowActivityIndicatorView(true)
                cell.imgProfile.sd_setIndicatorStyle(.gray)
                cell.imgProfile.sd_setImage(with: imgUrl, completed: nil)
            }
            if let name  = objData.commentAuthor {
                cell.lblName.text = name
            }
            if let msg = objData.commentContent {
                cell.lblReply.text = msg
            }
            if let date = objData.commentDate {
                cell.lblDate.text = date
            }
            
            if let rplyButtonText = objData.replyBtnText {
                cell.oltReply.setTitle(rplyButtonText, for: .normal)
                cell.oltReply.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            }
            
            cell.ratingBar.isHidden = true
            cell.imgDate.translatesAutoresizingMaskIntoConstraints = false
            cell.imgDate.leftAnchor.constraint(equalTo: cell.imgProfile.rightAnchor, constant: 8).isActive = true
            
            if defaults.bool(forKey: "isGuest") {
                cell.oltReply.isHidden = true
            }
            else {
                 cell.oltReply.isHidden = false
                if objData.canReply {
                    cell.oltReply.isHidden = false
                    cell.btnReplyAction = { () in
                        let commentVC = self.storyboard?.instantiateViewController(withIdentifier: "ReplyCommentController") as! ReplyCommentController
                        commentVC.modalPresentationStyle = .overCurrentContext
                        commentVC.modalTransitionStyle = .flipHorizontal
                        commentVC.isFromReplyComment = true
                        commentVC.objBlog = UserHandler.sharedInstance.objBlog
                        commentVC.comment_id = objData.commentId
                        self.presentVC(commentVC)
                    }
                }
                else {
                    cell.oltReply.isHidden = true
                }
            }
            
            return cell
        }
            
        else if section == 3 {
            let cell: CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let objData = replyArray[indexPath.row]
            
            if let name = objData.commentAuthor {
                cell.lblName.text = name
            }
            if let date = objData.commentDate {
                cell.lblDate.text = date
            }
            if let msg = objData.commentContent {
                cell.lblReply.text = msg
            }
            if let imgUrl = URL(string: objData.img) {
                cell.imgPicture.sd_setShowActivityIndicatorView(true)
                cell.imgPicture.sd_setIndicatorStyle(.gray)
                cell.imgPicture.sd_setImage(with: imgUrl, completed: nil)
            }
            
            return cell
        }
        else if section == 4 {
            if defaults.bool(forKey: "isGuest") {
                
            }
            else {
                let cell: AdRatingCell = tableView.dequeueReusableCell(withIdentifier: "AdRatingCell", for: indexPath) as! AdRatingCell
                let objData = dataArray[indexPath.row]
                let data = UserHandler.sharedInstance.objBlog
                
                cell.ratingBar.isHidden = true
                
                if objData.post.commentStatus == "open" {
                    if objData.post.hasComment {
                        cell.lblTitle.text = ""
                    }
                    else {
                        if let commentMsg = objData.post.commentMesage {
                            cell.lblTitle.text = commentMsg
                            cell.lblTitle.textAlignment = .center
                        }
                    }
                    if let commentTitle = data?.extra.commentForm.title {
                        cell.lblPostComment.text = commentTitle
                    }
                    if let txtTitle = data?.extra.commentForm.textarea {
                        cell.txtComment.placeholder = txtTitle
                    }
                    if let btnTitle = data?.extra.commentForm.btnSubmit {
                        cell.oltSubmitRating.setTitle(btnTitle, for: .normal)
                    }
                    
                    cell.btnSubmitAction = { () in
                        
                        guard let txtComment = cell.txtComment.text else {
                            return
                        }
                        if txtComment == "" {
                            
                        }
                        else {
                            var postID = 0
                            if let id = objData.post.postId {
                                postID = id
                            }
                            let param: [String: Any] = ["comment_id": "", "post_id": postID, "message": txtComment]
                            print(param)
                            self.adForest_blogPostComment(param: param as NSDictionary)
                        }
                    }
                }
                    
                else if objData.post.commentStatus == "closed" {
                    if let commentMsg = objData.post.commentMesage {
                        cell.lblTitle.text = commentMsg
                        cell.lblTitle.textAlignment = .center
                    }
                    cell.oltSubmitRating.isHidden = true
                    cell.txtComment.isHidden = true
                }
                    return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        let section = indexPath.section
        var height: CGFloat = 0.0
        if section == 0 {
            let objData = dataArray[indexPath.row]
            if objData.post.hasImage {
                height = 230
            }
            else if objData.post.hasImage == false {
                height = 70
            }
        }
    
        else if section == 1 {
            height = contentHeight[indexPath.row]

        }
        else if section == 2 {
            height = UITableViewAutomaticDimension
        }
        else if section == 3 {
            height = UITableViewAutomaticDimension
        }
        else if section == 4 {
            if defaults.bool(forKey: "isGuest") {
                height = 0
            }
            else {
                let objData = dataArray[indexPath.row]
                if objData.post.commentStatus == "open" {
                    height = 220
                }
                else if objData.post.commentStatus == "closed" {
                    height = 50
                }
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if contentHeight[webView.tag] != 0.0 {
            return
        }
        contentHeight[webView.tag] = webView.scrollView.contentSize.height
        tableView.reloadRows(at: [IndexPath(row: webView.tag, section: 0)], with: .automatic )
    }
    
    
    //MARK:- IBActions
    @IBAction func actionAdPost(_ sender: Any) {
        let adPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AadPostController") as! AadPostController
        self.navigationController?.pushViewController(adPostVC, animated: true)
    }
    //MARK:- API Call
    
    func adForest_blogDetail(parameter: NSDictionary) {
        self.showLoader()
        UserHandler.blogDetail(parameter: parameter, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
            self.title = successResponse.extra.pageTitle
            UserHandler.sharedInstance.objBlog = successResponse
            self.dataArray = [successResponse.data]
            self.commentArray = successResponse.data.post.comments.comments
            // capture reply from comments
                for reply in successResponse.data.post.comments.comments {
                    self.replyArray = reply.reply
                }
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
    
    // blog post comment
    func adForest_blogPostComment(param: NSDictionary) {
        self.showLoader()
        UserHandler.blogPostComment(parameter: param, success: { (successResponse) in
            self.stopAnimating()
            if successResponse.success {
                let alert = Constants.showBasicAlert(message: successResponse.message)
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
