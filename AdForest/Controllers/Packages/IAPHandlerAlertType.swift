//
//  IAPHandler.swift
//  AdForest
//
//  Created by Apple on 22/06/2018.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}
