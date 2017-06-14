//
//  NewsCell.swift
//  ZhihuDaily
//
//  Created by limboy on 14/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// MARK: NewsCell
class NewsCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    func configure(_ newsItem: NewsItem, favTapHandler: @escaping (UIButton) -> Void) {
        self.textLabel?.text = newsItem.title
        
        let button = UIButton(type: .system)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        
        if (NewsFeedViewModel.favedNews.value.contains(newsItem)) {
            button.setTitle("♥︎", for: .normal)
            button.tag = 1
        } else {
            button.setTitle("♡", for: .normal)
            button.tag = 0
        }
        
        button.rx.tap.asObservable()
            .subscribe(onNext:{ item in
                favTapHandler(button)
            }).addDisposableTo(self.disposeBag)
        
        self.accessoryView = button
    }
}
