//
//  NewsFeedViewController.swift
//  ZhihuDaily
//
//  Created by limboy on 07/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class NewsFeedViewController: UITableViewController {
    
    fileprivate let viewModel: NewsFeedViewModel = NewsFeedViewModel()
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    fileprivate let refreshIndicator: UIRefreshControl = UIRefreshControl()
    
    fileprivate let initialLoadingIndicator = UIActivityIndicatorView()
    
    fileprivate let reloadButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 32, y: 100, width: 64, height: 32)
        button.setTitle("Reload", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        // MARK: tableView
        ({
            tableView.frame = view.frame
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            // tableView.isHidden = true
        })()
        
        // MARK: refreshIndicator
        ({
            if #available(iOS 10.0, *) {
                refreshIndicator.addTarget(self, action: #selector(onRefreshEventChanged(sender:)), for: .valueChanged)
                tableView.refreshControl = refreshIndicator
            }
            view.addSubview(refreshIndicator)
        })()
        
        // MARK: initialLoadingIndicator
        ({
            initialLoadingIndicator.frame = CGRect(origin: CGPoint.init(x: UIScreen.main.bounds.width / 2 - 32, y: 100),
                                                   size: CGSize.init(width: 64, height: 64))
            initialLoadingIndicator.activityIndicatorViewStyle = .whiteLarge
            initialLoadingIndicator.color = .gray
            view.addSubview(initialLoadingIndicator)
            initialLoadingIndicator.startAnimating()
        })()
        
        // MARK: reload button
        ({
            view.addSubview(reloadButton)
            reloadButton.isHidden = true
            reloadButton.rx.tap.subscribe(onNext: { [unowned self] item in
                self.viewModel.initialRefresh()
            }).addDisposableTo(disposeBag)
        })()

        handleDataChange()
        
        viewModel.initialRefresh()
    }
    
    func onRefreshEventChanged(sender: UIRefreshControl) {
        if (sender.isRefreshing) {
            viewModel.refresh()
        }
    }
}

extension NewsFeedViewController {
    func handleDataChange() {
        viewModel.news.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[unowned self] item in
                
                if case .failure(let error) = item.loadingStatus {
                    dump(error)
                    if (self.initialLoadingIndicator.isAnimating) {
                        self.reloadButton.isHidden = false
                    }
                }
                
                if (item.loadingStatus == .initialLoading) {
                    self.reloadButton.isHidden = true
                    self.initialLoadingIndicator.startAnimating()
                }
                
                if (item.loadingStatus != .loading &&
                    item.loadingStatus != .initialLoading &&
                    item.loadingStatus != .none) {
                    
                    self.initialLoadingIndicator.stopAnimating()
                    self.refreshIndicator.endRefreshing()
                }
                
                if (item.loadingStatus == .loaded) {
                    self.tableView.reloadData()
                }
                
            }).addDisposableTo(disposeBag)
    }
}

extension NewsFeedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.value.currentNews?.news?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let newsItem: NewsItem = viewModel.news.value.currentNews!.news![indexPath.row]
        cell?.textLabel?.text = newsItem.title
        return cell!
    }
}
