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

class NewsDetailViewController: UIViewController {
    
    var webView = UIWebView()
    
    let viewModel = NewsDetaiViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        webView.frame = view.frame
        view.addSubview(webView)
        handleDataChange()
        if let id = self.getExtra("id") as? Int {
            viewModel.load(id)
        }
    }
}

extension NewsDetailViewController {
    func handleDataChange() {
        NewsDetaiViewModel.newsDetail.asObservable()
            .subscribe(onNext:{ [unowned self] item in
                if let item = item {
                    let request = URLRequest(url: URL(string: item.shareURL)!)
                    self.webView.loadRequest(request)
                }
        }).addDisposableTo(disposeBag)
    }
}
