//
//  NewsFeedViewModel.swift
//  ZhihuDaily
//
//  Created by limboy on 07/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import RxSwift

class NewsFeedViewModel {
    let refreshingStatus: Observable<LoadResult<[News]?>>
    
    static let disposeBag: DisposeBag = DisposeBag()
    
    init() {
        refreshingStatus = Observable.create({(observer) -> Disposable in
            observer.on(.next(LoadResult.loading))
                NewsFeedRepository.news.subscribe(onNext: { item in
            }).disposed(by: NewsFeedViewModel.disposeBag)
            
            return Disposables.create()
        })
    }
}
