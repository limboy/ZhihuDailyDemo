//
//  NewsFeedViewModel.swift
//  ZhihuDaily
//
//  Created by limboy on 07/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import RxSwift

enum LoadingStatus<T> {
    case loading
    case loaded(T)
    case failed(Error)
}

class NewsFeedViewModel {
    let refreshingStatus: Observable<LoadingStatus<[News]?>>
    init() {
        refreshingStatus = Observable.create({ (observer) -> Disposable in
            observer.on(.next(LoadingStatus.loading))
            return Disposables.create()
        })
    }
}
