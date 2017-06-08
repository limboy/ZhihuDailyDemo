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
    private let tableView: UITableView = {
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
    }
}

extension NewsFeedViewController {
    func handleDataChange() {
        viewModel.refreshingStatus.subscribe(onNext: { item in
            print(item)
        }).disposed(by: disposeBag)
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    
}

extension NewsFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = "Hello World"
        return cell!
    }
}
