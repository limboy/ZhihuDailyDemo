//
//  CartService.swift
//  ZhihuDaily
//
//  Created by limboy on 11/05/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation

protocol CartServiceProtocol {
    func getCartItemCount() -> Int
}

extension CartServiceProtocol {
    func getCartItemCount() -> Int {
        return 3
    }
}

class CartService: CartServiceProtocol {}
