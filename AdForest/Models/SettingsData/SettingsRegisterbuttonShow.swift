//
//  SettingsRegisterbuttonShow.swift
//  Adforest
//
//  Created by apple on 3/7/18.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation


struct SettingsRegisterbuttonShow {
 
    var facebook : Bool!
    var google : Bool!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        facebook = dictionary["facebook"] as? Bool
        google = dictionary["google"] as? Bool
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if facebook != nil{
            dictionary["facebook"] = facebook
        }
        if google != nil{
            dictionary["google"] = google
        }
        return dictionary
    }
    
}
