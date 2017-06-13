//
// Created by limboy on 09/05/2017.
// Copyright (c) 2017 limboy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UINavigationController {
    static func current() -> UINavigationController {
        return UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
    }
}
