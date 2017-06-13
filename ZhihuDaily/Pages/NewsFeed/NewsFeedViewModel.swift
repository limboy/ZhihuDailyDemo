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

    let disposeBag: DisposeBag = DisposeBag()
    
    var news:Variable<ResultModel<NewsItem>> = Variable(ResultModel())
    
    var favedNews: Variable<[NewsItem]> = Variable([])
    
    private var offset: String = ""
    
    func initialLoading() {
        loadData(.initial)
    }
    
    func refresh() {
        loadData(.refresh)
    }
    
    func loadMore() {
        loadData(.more, offset: offset)
    }
    
    func toggleFav(_ newsItem: NewsItem) {
        var newslist = favedNews.value
        let index = newslist.index(of: newsItem)
        if let index = index {
            newslist.remove(at: index)
        } else {
            newslist.append(newsItem)
        }
        favedNews.value = newslist
    }
    
    func loadData(_ loadingType: LoadingType, offset: String = "") {
        if (news.value.loadingStatus == .loading) {
            return
        }

        var value = news.value
        
        value.loadingStatus = .loading
        value.loadingType = loadingType
        news.value = value
        
        NewsFeedRepository.news(offset).asObservable().delaySubscription(1, scheduler: MainScheduler.instance).subscribe(onNext: {[unowned self] (result) in
            let parsedResult = self._parseResult(result: result)
            var value = self.news.value
            value.previousItems = self.news.value.currentItems
            
            if value.loadingType == .more {
                value.currentItems = value.previousItems + (parsedResult?.news ?? [])
            } else {
                value.currentItems = parsedResult?.news ?? []
            }
            
            value.loadingStatus = .loaded
            self.news.value = value
            self.offset = parsedResult?.date ?? ""
        }, onError: { (error) in
            self.news.value.loadingStatus = .failure(error)
        }, onCompleted: {
            
        }) { 
            
        }.addDisposableTo(disposeBag)
    }
    
}

private extension NewsFeedViewModel {
    
    func _parseResult(result: [String:Any]?) -> NewsList? {
        
        var news:[NewsItem] = []
        var newslist: NewsList?
        
        if let stories = result?["stories"] as? [[String:Any]] {
            for story in stories {
                let newsItem = NewsItem(id: story["id"] as! NSNumber,
                                        images: story["images"] as! [String],
                                        title: story["title"] as! String)
                news.append(newsItem)
            }
            
            newslist = NewsList(news: news, date: result?["date"] as! String)
        }
        
        return newslist
    }
}
