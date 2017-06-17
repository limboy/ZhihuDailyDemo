//
//  NewsDetailViewModel.swift
//  ZhihuDaily
//
//  Created by limboy on 14/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import RxSwift

class NewsDetailViewModel {
    
    static var newsDetail = Variable<NewsDetail?>(nil)
    
    static var newsItem: Variable<NewsItem>?
    
    private let disposeBag = DisposeBag()
    
    func load(_ id: Int) {
        NewsDetailRepository.detail(id)
            .subscribe(onNext: { [unowned self] item in
                let result = self._parseResult(result: item)
                NewsDetailViewModel.newsDetail.value = result
            })
            .addDisposableTo(disposeBag)
    }

}

private extension NewsDetailViewModel {
    
    func _parseResult(result: [String:Any]?) -> NewsDetail {
        
        var detail = NewsDetail()
        detail.id = result?["id"] as? Int ?? 0
        detail.body = result?["body"] as? String ?? ""
        detail.shareURL = result?["share_url"] as? String ?? ""
        detail.title = result?["title"] as? String ?? ""
        
        return detail
    }
}
