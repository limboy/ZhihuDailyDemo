//
//  NewsFeedRepository.swift
//  ZhihuDaily
//
//  Created by limboy on 07/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import RxSwift

class NewsFeedRepository {
    static func news(_ offset: String = "") -> Observable<[String:Any]?> {
        return Observable.create({ observer in
            let path = offset.characters.count > 0 ? "/api/4/news/before/\(offset)" : "/api/4/news/latest"
            let resource = Resource(path: path, method: .GET, requestBody: nil, headers: ["Content-Type": "application/json"], parse: decodeJSON)
            
            apiRequest(baseURL: URL(string: "https://news-at.zhihu.com")!, resource: resource, failure: { (reason, result) in
                observer.on(.error(reason))
            }, success: { result in
                observer.on(.next(result))
                observer.on(.completed)
            })
            
            return Disposables.create()
        })
    }
}
