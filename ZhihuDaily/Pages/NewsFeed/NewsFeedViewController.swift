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

class HomeViewController: UIViewController {
    
    fileprivate let segmentControl: UISegmentedControl = UISegmentedControl(items: ["Latest", "Favorites"])
    
    fileprivate let feedsViewController: NewsFeedViewController = NewsFeedViewController()
    
    override func viewDidLoad() {
        // MARK: segment controls
        ({
            segmentControl.selectedSegmentIndex = 0
            
            segmentControl.rx.value.asObservable()
                .subscribe(onNext:{ [weak self] index in
                    if (index == 0) {
                    } else {
                    }
                })
            
            navigationItem.titleView = segmentControl
        })()
        
        // MARK: add child view controller
        ({
            self.addChildViewController(feedsViewController)
            self.view.addSubview(feedsViewController.view)
        })()
    }
}

class FavedViewController: UITableViewController {
    fileprivate let viewModel: NewsFeedViewModel = NewsFeedViewModel()
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        // MARK: tableView
        ({
            tableView.frame = view.frame
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(NewsCell.self, forCellReuseIdentifier: "Cell")
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            // tableView.isHidden = true
        })()
    }
}

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
        let newsItem: NewsItem = NewsFeedViewModel.news.value.currentItems[indexPath.row]
        
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
}
