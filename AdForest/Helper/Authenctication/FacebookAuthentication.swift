//
//  FacebookAuthentication.swift
//  GoRich
//
//  Created by Apple PC on 23/08/2017.
//  Copyright © 2017 My Technology. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookAuthentication {

    class var token: String? {
        
        if FBSDKAccessToken.current() != nil {
            return FBSDKAccessToken.current().tokenString
        } else {
            return nil
        }
    }

    class var isLoggedIn: Bool {
    
        return FBSDKAccessToken.current() != nil
    
    }
    
    class func signOut() {
    
        if isLoggedIn {
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
    }
   
    class func isValidatedWithUrl(url: URL) -> Bool {
        return url.scheme!.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize"
    }
}
