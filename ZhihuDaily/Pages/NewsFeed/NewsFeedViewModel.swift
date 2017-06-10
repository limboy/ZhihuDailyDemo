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
    
    struct News {
        var loadingStatus: ResultLoadingStatus = .none
        var previousNews: NewsList?
        var currentNews: NewsList?
    }
    
    let disposeBag: DisposeBag = DisposeBag()
    
    var news:Variable<News> = Variable(News())
    
    func initialRefresh() {
        _refresh(isInitial: true)
    }
    
    func refresh() {
        _refresh(isInitial: false)
    }
    
    func loadMore() {
        
    }
}

private extension NewsFeedViewModel {
    
    func _refresh(isInitial: Bool) {
        var newsValue = news.value
        
        guard newsValue.loadingStatus != .loading else {
            return
        }
        
        newsValue.loadingStatus = isInitial ? .initialLoading : .loading
        news.value = newsValue
        
        NewsFeedRepository.news
            .delaySubscription(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (item) in
                
                newsValue.loadingStatus = .loaded
                newsValue.previousNews = newsValue.currentNews
                newsValue.currentNews = self._parseResult(result: item)
                self.news.value = newsValue
                
                }, onError: { (error) in
                    
                    newsValue.loadingStatus = .failure(error)
                    self.news.value = newsValue
                    
            }, onCompleted: {
                
            }, onDisposed: {
                
            }).addDisposableTo(disposeBag)
    }
    
    func _parseResult(result: [String:Any]?) -> NewsList? {
        
        var news:[NewsItem] = []
        var newslist: NewsList?
        
        if let stories = result?["stories"] as? [[String:Any]] {
            for story in stories {
                let newsItem = NewsItem(id: story["id"] as! NSNumber,
                                        images: story["images"] as? [String],
                                        title: story["title"] as! String)
                news.append(newsItem)
            }
            
            newslist = NewsList(news: news, date: result?["date"] as! String)
        }
        
        return newslist
    }
}
