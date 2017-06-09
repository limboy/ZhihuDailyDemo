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

class NewsFeedViewController: UIViewController {
    fileprivate let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    fileprivate let viewModel: NewsFeedViewModel = NewsFeedViewModel()
    
    fileprivate let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        tableView.frame = view.frame
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        handleDataChange()
        
        viewModel.refresh()
    }
}

extension NewsFeedViewController {
    func handleDataChange() {
        viewModel.news.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {item in
                dump(item)
                self.tableView.reloadData()
            }).addDisposableTo(disposeBag)
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    
}

extension NewsFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.value.currentNews?.news?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let newsItem: NewsItem = viewModel.news.value.currentNews!.news![indexPath.row]
        cell?.textLabel?.text = newsItem.title
        return cell!
    }
}
