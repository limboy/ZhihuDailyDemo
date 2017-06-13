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
import Diff
import ESPullToRefresh

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
    
    fileprivate let loadMoreIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.isHidden = true
        return indicator
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
                self.reloadButton.isHidden = true
                self.viewModel.initialLoading()
            }).addDisposableTo(disposeBag)
        })()
        
        // MARK: load more indicator
        ({
            self.tableView.es_addInfiniteScrolling {
                self.viewModel.loadMore()
            }
        })()

        handleDataChange()
        
        viewModel.initialLoading()
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
                
                if item.loadingStatus != .loading {
                    self.initialLoadingIndicator.stopAnimating()
                    self.refreshIndicator.endRefreshing()
                    self.tableView.es_stopLoadingMore()
                }
                
                if item.loadingStatus == .loaded {
                    self.tableView.animateRowChanges(oldData: item.previousItems, newData: item.currentItems)
                }
                
                if item.loadingType == .initial && item.loadingStatus == .loading {
                    self.initialLoadingIndicator.startAnimating()
                }
                
                if case .failure(let error) = item.loadingStatus {
                    dump(error)
                    if item.loadingType == .initial {
                        self.reloadButton.isHidden = false
                    }
                }
                
            }).addDisposableTo(disposeBag)
    }
}

extension NewsFeedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.value.currentItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let newsItem: NewsItem = viewModel.news.value.currentItems[indexPath.row]
        cell?.textLabel?.text = newsItem.title
        return cell!
    }
}
