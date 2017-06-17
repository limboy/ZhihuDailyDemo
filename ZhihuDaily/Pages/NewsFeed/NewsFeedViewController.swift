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

// MARK: HomeViewController
class HomeViewController: UIViewController {
    
    fileprivate let segmentControl = UISegmentedControl(items: ["Latest", "Favorites"])
    
    fileprivate let feedsViewController = NewsFeedViewController()
    
    fileprivate let favedViewController = FavedViewController()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        // MARK: segment controls
        ({
            segmentControl.selectedSegmentIndex = 0
            
            segmentControl.rx.value.asObservable()
                .subscribe(onNext:{ [unowned self] index in
                    if (index == 0) {
                        self.favedViewController.view.isHidden = true
                        self.feedsViewController.view.isHidden = false
                    } else {
                        self.favedViewController.view.isHidden = false
                        self.feedsViewController.view.isHidden = true
                    }
                }).addDisposableTo(disposeBag)
            
            navigationItem.titleView = segmentControl
        })()
        
        // MARK: add child view controller
        ({
            self.addChildViewController(feedsViewController)
            self.view.addSubview(feedsViewController.view)
            
            self.addChildViewController(favedViewController)
            self.view.addSubview(favedViewController.view)
            favedViewController.view.isHidden = true
        })()
    }
}


// MARK: FavedViewController
class FavedViewController: UITableViewController {
    fileprivate let viewModel: NewsFeedViewModel = NewsFeedViewModel()
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        // MARK: tableView
        ({
            tableView.frame = view.frame
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(NewsCell.self, forCellReuseIdentifier: "Cell")
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            // tableView.isHidden = true
        })()
        
        handleDataChange()
    }
}

extension FavedViewController {
    func handleDataChange() {
        NewsFeedViewModel.favedNews.asObservable().subscribe(onNext:{[unowned self] item in
            self.tableView.reloadData()
        }).addDisposableTo(disposeBag)
    }
}

extension FavedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewsFeedViewModel.favedNews.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NewsCell
        var newsItem: NewsItem = NewsFeedViewModel.favedNews.value[indexPath.row]
        
        cell.configure(newsItem) { [unowned self] (button) in
            if button.tag == 0 {
                button.tag = 1
                button.setTitle("♥︎", for: .normal)
            } else {
                button.tag = 0
                button.setTitle("♡", for: .normal)
            }
            self.viewModel.toggleFav(newsItem)
            self.tableView.reloadData()
        }
        
        return cell
    }
}


// MARK: NewsFeedViewController
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
        tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)

        // MARK: tableView
        ({
            tableView.frame = view.frame
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(NewsCell.self, forCellReuseIdentifier: "Cell")
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
            tableView.es_addInfiniteScrolling {
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
        NewsFeedViewModel.news.asObservable()
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
        return NewsFeedViewModel.news.value.currentItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NewsCell
        var newsItem: NewsItem = NewsFeedViewModel.news.value.currentItems[indexPath.row]
        
        cell.configure(newsItem) { [unowned self] (button) in
            if button.tag == 0 {
                button.tag = 1
                button.setTitle("♥︎", for: .normal)
            } else {
                button.tag = 0
                button.setTitle("♡", for: .normal)
            }
            self.viewModel.toggleFav(newsItem)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsItem: NewsItem = NewsFeedViewModel.news.value.currentItems[indexPath.row]
        Router.to(.detail, parameters: ["id": newsItem.id])
    }
}
