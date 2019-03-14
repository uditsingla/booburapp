//
//  IAPService.swift
//  AdForest
//
//  Created by Apple on 22/06/2018.
//  Copyright © 2018 apple. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    
    static let shared = IAPService()
    
    private override init() {
    }
    
    var products = [SKProduct]()
    
    
    
    func getProducts() {
        
        let products: Set = [IAPProduct.premium.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
    }
    
    
}


extension IAPService : SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        self.products = response.products
        
        for product in response.products{
            print(product.localizedTitle)
            print(product.localizedDescription)
            
        }
    }
    
}
