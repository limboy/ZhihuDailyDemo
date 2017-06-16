//
//  Route.swift
//  ZhihuDaily
//
//  Created by limboy on 09/05/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import UIKit

enum RouterTable: String {
    case home = "home"
    case detail = "detail/:id"
    
    func asController() -> UIViewController.Type {
        switch self {
        case .home:
            return NewsFeedViewController.self
        case .detail:
            return NewsDetailViewController.self
        }
    }
}

class Router {
    static func to(_ route: RouterTable, parameters: Dictionary<String, Any>?) -> Void {
        let viewController = route.asController().init()

        if let parameters = parameters {
            for (key, value) in parameters {
                viewController.putExtra(key, value)
            }
        }

        //TODO: 添加 shouldBePushed 调用，比如有些页面需要先登录
        DispatchQueue.main.async {
            UINavigationController.current().pushViewController(viewController, animated: true)
        }
    }
}

extension Router {
    func parseURL(_ url: String) -> (RouterTable, Dictionary<String, String>?) {
        //TODO: add implementation
        return (.home, nil)
    }
}
