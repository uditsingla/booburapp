//
//  AdPostMap.swift
//  AdForest
//
//  Created by apple on 4/25/18.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation

struct AdPostMap{
    
    var locationLat : AdPostLocation!
    var locationLong : AdPostLocation!
    var onOff : Bool!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        if let locationLatData = dictionary["location_lat"] as? [String:Any]{
            locationLat = AdPostLocation(fromDictionary: locationLatData)
        }
        if let locationLongData = dictionary["location_long"] as? [String:Any]{
            locationLong = AdPostLocation(fromDictionary: locationLongData)
        }
        onOff = dictionary["on_off"] as? Bool
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if locationLat != nil{
            dictionary["location_lat"] = locationLat.toDictionary()
        }
        if locationLong != nil{
            dictionary["location_long"] = locationLong.toDictionary()
        }
        if onOff != nil{
            dictionary["on_off"] = onOff
        }
        return dictionary
    }
    
}
