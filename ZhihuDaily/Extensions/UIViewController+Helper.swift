//
//  UIViewController+Helper.swift
//  ZhihuDaily
//
//  Created by limboy on 15/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import UIKit

protocol ViewCotrollerIntent {
    func putExtra(_ key: String, _ value: Any)
    func getExtra(_ key: String) -> Any?
}

extension UIViewController: ViewCotrollerIntent {
    
    // 完美，what a trick
    private struct IntentStorage {
        static var extra: [String:Any] = [:]
    }
    
    func putExtra(_ key: String, _ value: Any) {
        IntentStorage.extra[key] = value
    }
    
    func getExtra(_ key: String) -> Any? {
        return IntentStorage.extra[key]
    }
}
