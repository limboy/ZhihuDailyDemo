//
//  NewsDetailRepository.swift
//  ZhihuDaily
//
//  Created by limboy on 14/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import RxSwift

class NewsDetailRepository {
    static func detail(_ id: Int) -> Observable<[String:Any]?> {
        return Observable.create({ observer in
            let resource = Resource(path: "/api/4/news/\(id)", method: .GET, requestBody: nil, headers: ["Content-Type": "application/json"], parse: decodeJSON)
            
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
