//
//  LeftController.swift
//  AdForest
//
//  Created by apple on 3/8/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NVActivityIndicatorView

enum leftMenues : Int {
    case main = 1
    case profile
    case advancedSearch
    case mapList
    case contactUs
    /*
    case messages
    case packages
    case myAds
    case inactiveAds
    case featuredAds
    case favAds
     */
}

enum pageMenu: Int {
    case detailPage = 1
    case termsPage = 2
}


enum GuestMenu: Int {
    case main = 1
    case advancedSearch
    case mapList
    case login
    case register
    /*
    case packages
     */
}

enum OtherGuestMenues: Int {
    case blog = 1
}

enum OtherMenues: Int {
    case blog = 1
    case logout
}

protocol leftMenuProtocol {
    func changeViewController(_ menu : leftMenues)
}


protocol guestMenuProtocol {
    func changeGuestController(_ menu : GuestMenu)
}

//Pages Protocol
protocol changePagesProtocol {
    func changePage(_ menu : pageMenu)
}

protocol changeOtherMenuesProtocol {
    func changeMenu(_ other: OtherMenues )
}

protocol changeOtherGuestProtocol {
    func changeGuestMenu(_ other: OtherGuestMenues)
}


class LeftController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, leftMenuProtocol , changeOtherMenuesProtocol , guestMenuProtocol, changeOtherGuestProtocol, changePagesProtocol {
    
    @IBOutlet weak var imgProfilePicture: UIImageView! {
        didSet {
            imgProfilePicture.round()
        }
    }
    
    @IBOutlet weak var containerViewImage: UIView! 
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorColor = UIColor.darkGray
            tableView.separatorStyle = .singleLineEtched
        }
    }
    
    //MARK:- Properties
    
    var defaults = UserDefaults.standard
    
    let sectionTwo = ["Page 1", "Page 2"]
    
    var pagesArray = [String]()
    //#imageLiteral(resourceName: "packages"),
    // #imageLiteral(resourceName: "myads"), #imageLiteral(resourceName: "inactiveads")
    var imagesArray = [#imageLiteral(resourceName: "home"), #imageLiteral(resourceName: "profile"), #imageLiteral(resourceName: "search"), #imageLiteral(resourceName: "location"), #imageLiteral(resourceName: "favourite")]
    var guestImagesArray = [#imageLiteral(resourceName: "home"), #imageLiteral(resourceName: "search"), #imageLiteral(resourceName: "location"), #imageLiteral(resourceName: "logout"), #imageLiteral(resourceName: "profile")]
    var othersArrayImages = [#imageLiteral(resourceName: "blog"),#imageLiteral(resourceName: "logout")]
    var pageImages = [#imageLiteral(resourceName: "about"),#imageLiteral(resourceName: "faq")]
    
    //var guestOtherArray = [#imageLiteral(resourceName: "blog")]
    
    var viewHome: UIViewController!
    var viewProfile: UIViewController!
    var viewAdvancedSearch: UIViewController!
    var viewMessages: UIViewController!
    var viewPackages: UIViewController!
    var viewMyAds: UIViewController!
    var viewInactiveAds: UIViewController!
    var viewFeaturedAds: UIViewController!
    var viewFavAds: UIViewController!
    var viewContactUs: UIViewController!
    
    var viewLogin: UIViewController!
    var viewRegister: UIViewController!
    var mapList: UIViewController!
    
    // Pages Controller
    
    var viewPages: UIViewController!
    var termsPage: UIViewController!
    
    //Other Menues
    var viewBlog : UIViewController!
    var viewlogout: UIViewController!
    // var dataToShow = UserHandler.sharedInstance.objSettingsMenu
    
    
    //MARK:- Application Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.bool(forKey: "isGuest") {
            self.initializeGuestViews()
            self.initializeOtherGuestViews()
        }
        else {
            self.initializeViews()
            self.initializePagesView()
            self.initializeOtherViews()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.NotificationName.updateUserProfile), object: nil, queue: nil) { (notification) in
            self.adForest_populateData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Google Analytics Track data
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Left Controller")
        guard let builder = GAIDictionaryBuilder.createScreenView() else {return}
        tracker?.send(builder.build() as [NSObject: AnyObject])
        self.adForest_populateData()
    }
    
    //MARK:- custom
    func showLoader() {
        self.startAnimating(Constants.activitySize.size, message: Constants.loaderMessages.loadingMessage.rawValue,messageFont: UIFont.systemFont(ofSize: 14), type: NVActivityIndicatorType.ballClipRotatePulse)
    }
    
    func adForest_populateData() {
        if let mainColor = defaults.string(forKey: "mainColor") {
            self.containerViewImage.backgroundColor = Constants.hexStringToUIColor(hex: mainColor)
        }
        if defaults.bool(forKey: "isGuest") {
            if let settingsInfo = defaults.object(forKey: "settings") {
                let  settingObject = NSKeyedUnarchiver.unarchiveObject(with: settingsInfo as! Data) as! [String : Any]
                print(settingObject)
                
                let model = SettingsRoot(fromDictionary: settingObject)
                print(model)
                
                if let imgUrl = URL(string: model.data.guestImage) {
                    self.imgProfilePicture.sd_setImage(with: imgUrl, completed: nil)
                    self.imgProfilePicture.sd_setShowActivityIndicatorView(true)
                    self.imgProfilePicture.sd_setIndicatorStyle(.gray)
                }
                if let name = model.data.guestName {
                    self.lblName.text = name
                }
            }
        }
        else {
            if let userInfo = defaults.object(forKey: "userData") {
                let objUser = NSKeyedUnarchiver.unarchiveObject(with: userInfo as! Data) as! [String: Any]
                
                let userModel = UserRegisterRoot(fromDictionary: objUser)
                
                if let profileImage = userModel.data.profileImg {
                    if let imgUrl = URL(string: profileImage) {
                        self.imgProfilePicture.sd_setImage(with: imgUrl, completed: nil)
                        self.imgProfilePicture.sd_setShowActivityIndicatorView(true)
                        self.imgProfilePicture.sd_setIndicatorStyle(.gray)
                    }
                }
                
                if let name = userModel.data.displayName {
                    self.lblName.text = name
                }
                if let email = userModel.data.userEmail {
                    self.lblEmail.text = email
                }
            }
        }
    }
    
    
    func changeViewController(_ menu: leftMenues) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.viewHome, close: true)
        case .profile:
            self.slideMenuController()?.changeMainViewController(self.viewProfile, close: true)
        case .advancedSearch:
            self.slideMenuController()?.changeMainViewController(self.viewAdvancedSearch, close: true)
        case .mapList:
            self.slideMenuController()?.changeMainViewController(self.mapList, close: true)
        case .contactUs:
            self.slideMenuController()?.changeMainViewController(self.viewContactUs, close: true)
        /*
        case .messages:
            self.slideMenuController()?.changeMainViewController(self.viewMessages, close: true)
        case .packages:
              self.slideMenuController()?.changeMainViewController(self.viewPackages, close: true)
        case .myAds:
            self.slideMenuController()?.changeMainViewController(self.viewMyAds, close: true)
        case .inactiveAds:
            self.slideMenuController()?.changeMainViewController(self.viewInactiveAds, close: true)
        case .featuredAds:
             self.slideMenuController()?.changeMainViewController(self.viewFeaturedAds, close: true)
        case .favAds:
            self.slideMenuController()?.changeMainViewController(self.viewFavAds, close: true)
        */
        }
    }
    
    func changePage(_ menu: pageMenu) {
        switch menu {
        case .detailPage:
            self.slideMenuController()?.changeMainViewController(self.viewPages, close: true)
        case .termsPage:
            self.slideMenuController()?.changeMainViewController(self.termsPage, close: true)
        default:
            break
        }
    }
    
    
    
    func changeGuestController(_ menu: GuestMenu) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.viewHome, close: true)
        case .advancedSearch:
            self.slideMenuController()?.changeMainViewController(self.viewAdvancedSearch, close: true)
        case .mapList:
            self.slideMenuController()?.changeMainViewController(self.mapList, close: true)
            /*
        case .packages:
            self.slideMenuController()?.changeMainViewController(self.viewPackages, close: true)
             */
        case .login:
            self.slideMenuController()?.changeMainViewController(self.viewLogin, close: true)
        case .register:
            self.slideMenuController()?.changeMainViewController(self.viewRegister, close: true)
        }
    }
    
    
    func initializeViews() {
        let homeView = storyboard?.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        self.viewHome = UINavigationController(rootViewController: homeView)
        
        let profileView = storyboard?.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
        self.viewProfile = UINavigationController(rootViewController: profileView)
        
        let searchView = storyboard?.instantiateViewController(withIdentifier: "AdvancedSearchController") as! AdvancedSearchController
        searchView.delegate = self
        self.viewAdvancedSearch = UINavigationController(rootViewController: searchView)
        
        let messagesView = storyboard?.instantiateViewController(withIdentifier: "MessagesController") as! MessagesController
        messagesView.delegate = self
        self.viewMessages = UINavigationController(rootViewController: messagesView)
        
        let packageView = storyboard?.instantiateViewController(withIdentifier: "PackagesController") as! PackagesController
        self.viewPackages = UINavigationController(rootViewController: packageView)
        
        let myAdsView = storyboard?.instantiateViewController(withIdentifier: "MyAdsController") as! MyAdsController
        self.viewMyAds = UINavigationController(rootViewController: myAdsView)
        
        let inactiveAdsView = storyboard?.instantiateViewController(withIdentifier: "InactiveAdsController") as! InactiveAdsController
        self.viewInactiveAds = UINavigationController(rootViewController: inactiveAdsView)
        
        //  let featuredAdsView = storyboard?.instantiateViewController(withIdentifier: "FeaturedAdsController") as! FeaturedAdsController
        //  self.viewFeaturedAds = UINavigationController(rootViewController: featuredAdsView)
        
        let favAdsView = storyboard?.instantiateViewController(withIdentifier: "FavouriteAdsController") as! FavouriteAdsController
        self.viewFavAds = UINavigationController(rootViewController: favAdsView)
        
        let contactUSView = storyboard?.instantiateViewController(withIdentifier: "ContactUsController") as! ContactUsController
        self.viewContactUs = UINavigationController(rootViewController: contactUSView)
        
        let mapList = storyboard?.instantiateViewController(withIdentifier: "MarkersOnMapController") as! MarkersOnMapController
        mapList.isAllPlacesRequired = true
        mapList.delegate = self
        self.mapList = UINavigationController(rootViewController: mapList)
    }
    
    func initializePagesView() {
        let pagesView = storyboard?.instantiateViewController(withIdentifier: "AboutUsController") as! AboutUsController
        //  pagesView.delegate = self
        self.viewPages = UINavigationController(rootViewController: pagesView)
        let pagesView2 = storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        self.termsPage = UINavigationController(rootViewController: pagesView2)
    }
    
    
    func initializeGuestViews() {
        let homeView = storyboard?.instantiateViewController(withIdentifier: "HomeController") as! HomeController
        self.viewHome = UINavigationController(rootViewController: homeView)
        
        let searchView = storyboard?.instantiateViewController(withIdentifier: "AdvancedSearchController") as! AdvancedSearchController
        searchView.delegate = self
        self.viewAdvancedSearch = UINavigationController(rootViewController: searchView)
        
        let mapList = storyboard?.instantiateViewController(withIdentifier: "MarkersOnMapController") as! MarkersOnMapController
        mapList.isAllPlacesRequired = true
        mapList.delegate = self
        self.mapList = UINavigationController(rootViewController: mapList)
        
        /*
        let packageView = storyboard?.instantiateViewController(withIdentifier: "PackagesController") as! PackagesController
        self.viewPackages = UINavigationController(rootViewController: packageView)
        */
        
        let loginView = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.viewLogin = UINavigationController(rootViewController: loginView)
        
        let registerView = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        
        self.viewRegister = UINavigationController(rootViewController: registerView)
    }
    
    
    //Change Other Views
    func changeMenu(_ other: OtherMenues) {
        switch other {
        case .blog :
            self.slideMenuController()?.changeMainViewController(self.viewBlog, close: true)
        case .logout :
            self.logoutUser()
        default:
            break
        }
    }
    
    // change others guest menu
    func changeGuestMenu(_ other: OtherGuestMenues) {
        switch other {
        case .blog:
            self.slideMenuController()?.changeMainViewController(self.viewBlog, close: true)
        default:
            break
        }
    }
    
    
    func initializeOtherViews() {
        let blogView = self.storyboard?.instantiateViewController(withIdentifier: "BlogController") as! BlogController
        self.viewBlog = UINavigationController(rootViewController: blogView)
    }
    
    
    func initializeOtherGuestViews() {
        let blogView = self.storyboard?.instantiateViewController(withIdentifier: "BlogController") as! BlogController
        self.viewBlog = UINavigationController(rootViewController: blogView)
    }
    
    //MARK-: Logout user
    
    func logoutUser() {
        self.showLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.defaults.set(false, forKey: "isLogin")
            self.defaults.set(false, forKey: "isGuest")
            self.defaults.set(false, forKey: "isSocial")
            
            FacebookAuthentication.signOut()
            GoogleAuthenctication.signOut()
            self.appDelegate.moveToLogin()
            self.stopAnimating()
        }
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0
        if section == 0 {
            if defaults.bool(forKey: "isGuest"){
                value = 5
            }
            else {
                //value = 9
                value = 5
            }
        }
            
        else if section == 1 {
            if defaults.bool(forKey: "isGuest") {
                return 0
            }
            else {
                //if UserHandler.sharedInstance.objSettingsMenu.isEmpty {
                value = 2
                // }
                // value = UserHandler.sharedInstance.objSettingsMenu.count
            }
        }
            
        else if section == 2 {
            if defaults.bool(forKey: "isGuest"){
                return 1
            }
            else {
                value = 2
            }
        }
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LeftMenuCell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell", for: indexPath) as! LeftMenuCell
        
        let section = indexPath.section
        let row = indexPath.row
        let objData = UserHandler.sharedInstance.objSettings
        
        if section == 0 {
            if defaults.bool(forKey: "isGuest") {
                cell.imgPicture.image = guestImagesArray[indexPath.row]
                if row == 0 {
                    cell.lblName.text = objData?.menu.home
                }
                else if row == 1 {
                    cell.lblName.text = objData?.menu.search
                }
                else if row == 2 {
                     cell.lblName.text = "Map List"
                     }
                else if row == 3 {
                    cell.lblName.text = objData?.menu.login
                }
                else if row == 4 {
                    cell.lblName.text = objData?.menu.register
                }
            }
                
            else {
                cell.imgPicture.image = imagesArray[indexPath.row]
                if row == 0 {
                    cell.lblName.text = objData?.menu.home
                }
                else if row == 1 {
                    cell.lblName.text = objData?.menu.profile
                }
                else if row == 2 {
                    cell.lblName.text = objData?.menu.search
                }
                else if row == 3 {
                    cell.lblName.text = "Map List"
                }
//                else if row == 3 {
//                    cell.lblName.text = objData?.menu.messages
//                }
                    /*else if row == 4 {
                     cell.lblName.text = objData?.menu.packages
                     }
                     else if row == 5 {
                     cell.lblName.text = objData?.menu.myAds
                     }
                     else if row == 6 {
                     cell.lblName.text = objData?.menu.inactiveAds
                     }*/
                    //                else if row == 4 {
                    //                    cell.lblName.text = objData?.menu.featuredAds
                    //                }
//                else if row == 3 {
//                    cell.lblName.text = objData?.menu.favAds
//                }
                else if row == 4 {
                    cell.lblName.text = "Contact Us"
                }
            }
            
        }
        else if section == 1 {
            if defaults.bool(forKey: "isGuest") {
                
            }
            else {
                let objPages = UserHandler.sharedInstance.objSettingsMenu[indexPath.row]
                cell.lblName.text = objPages.pageTitle
                cell.imgPicture.image = pageImages[indexPath.row]

                //print("05")
                //print(objPages)
                //print("0505")
            }
        }
        else if section == 2 {
            /* if defaults.bool(forKey: "isGuest") {
             cell.imgPicture.image = guestOtherArray[indexPath.row]
             if row == 0 {
             //cell.lblName.text = objData?.menu.blog
             }
             } */
            
            cell.imgPicture.image = othersArrayImages[indexPath.row]
            if row == 0 {
                //cell.lblName.text = objData?.menu.blog
                //cell.lblName.text = ""
                cell.lblName.text = objData?.menu.blog
            }
            else if row == 1 {
                cell.lblName.text = objData?.menu.logout
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        let objData = UserHandler.sharedInstance.objSettings
        if defaults.bool(forKey: "isGuest") {
            if section == 0 {
                title = ""
            }
            else if section == 2 {
                title = (objData?.menu.others)!
            }
        }
        else {
            if section == 0 {
                title = ""
            }
            else if section == 1 {
                title = (objData?.menu.submenu.title)!
            }
            else if section == 2 {
                title = (objData?.menu.others)!
            }
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 {
            if defaults.bool(forKey: "isGuest") {
                if let menu = GuestMenu(rawValue: indexPath.row+1) {
                    self.changeGuestController(menu)
                }
            }
            else {
                if let menu = leftMenues(rawValue: indexPath.row+1) {
                    self.changeViewController(menu)

//                    if indexPath.row == 4 {
//                        self.changeViewController(.contactUs)
//                    }
//                    else {
//                        self.changeViewController(menu)
//                    }
                }
            }
        }
        else if section == 1 {
            if let menu = pageMenu(rawValue: indexPath.row+1) {// Contact button doesn't satify the if let condition
                
                self.changePage(menu)
            }
        }
            
        else if section == 2 {
            if defaults.bool(forKey: "isGuest") {
                if let menu = OtherGuestMenues(rawValue: indexPath.row+1) {
                    self.changeGuestMenu(menu)
                }
            }
            if let menu = OtherMenues(rawValue: indexPath.row+1) {
                self.changeMenu(menu)
            }
        }
    }
}
