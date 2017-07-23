//
//  NewsDetailViewController.swift
//  ZhihuDaily
//
//  Created by limboy on 14/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class NewsDetailViewController: UIViewController {
    
    var webView = UIWebView()
    
    var favButton = UIBarButtonItem(title: "♡", style: .plain, target: nil, action: nil)
    
    let viewModel = NewsDetailViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        // webview
        webView.frame = view.frame
        view.addSubview(webView)
        
        // favButton
        navigationItem.rightBarButtonItem = favButton
        favButton.rx.tap
            .subscribe(onNext: { item in
                if let newsItem = NewsDetailViewModel.newsItem {
                    var value = newsItem.value
                    value.hasFaved = !newsItem.value.hasFaved
                    newsItem.value = value
                }
            }).addDisposableTo(disposeBag)
        
        //
        // if let id = self.getExtra("id") as? Int {
            // viewModel.load(id)
        // }
        
        if let model = self.getExtra("model") as? Variable<NewsItem> {
            favButton.title = model.value.hasFaved ? "♥︎" : "♡"
            viewModel.load(Int(model.value.id))
            NewsDetailViewModel.newsItem = model
        }
        
        handleDataChange()
    }
}

extension NewsDetailViewController {
    func handleDataChange() {
        NewsDetailViewModel.newsDetail.asObservable()
            .subscribe(onNext:{ [unowned self] item in
                if let item = item {
                    let request = URLRequest(url: URL(string: item.shareURL)!)
                    self.webView.loadRequest(request)
                }
        }).addDisposableTo(disposeBag)
        
        NewsDetailViewModel.newsItem?.asObservable()
            .subscribe(onNext: { [unowned self] item in
                self.favButton.title = item.hasFaved ? "♥︎" : "♡"
            }).addDisposableTo(disposeBag)
    }
}
