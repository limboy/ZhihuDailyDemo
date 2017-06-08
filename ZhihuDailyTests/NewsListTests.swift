//
// Created by limboy on 13/05/2017.
// Copyright (c) 2017 limboy. All rights reserved.
//

import Foundation
import XCTest

import ReSwift
@testable import ZhihuDaily

class NewsListTests: XCTestCase {

    static let store: Store<NewsListState> = NewsListViewController().store

    override class func setUp() {
        super.setUp()
    }

    override class func tearDown() {
        super.tearDown()
    }

    func testAction() {
        let action = NewsListActions.initial(.loading)
        NewsListTests.store.dispatch(action)
    }
}
