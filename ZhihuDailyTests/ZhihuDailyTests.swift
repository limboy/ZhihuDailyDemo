//
//  ZhihuDailyTests.swift
//  ZhihuDailyTests
//
//  Created by limboy on 09/05/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import XCTest
@testable import ZhihuDaily
import ReSwift
import Diff

class CallbackStoreSubscriber<T>: StoreSubscriber {
    
    let handler: (T) -> Void
    
    init(handler: @escaping (T) -> Void) {
        self.handler = handler
    }
    
    func newState(state: T) {
        handler(state)
    }
}

enum Whatever {
    case east
    case whh
    case haha(Int)
}

class ZhihuDailyTests: XCTestCase {
    
    let store = NewsListViewController().store
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        var counter = 0
        var testCounter = 0
        
        let subscriber = CallbackStoreSubscriber<NewsListState> { [unowned self] state in
            counter += 1
            
            switch state.loadingStatus {
            case .None:
                XCTAssertTrue(counter == 1, "initial state")
                testCounter += 1
            case .initial(.loading):
                XCTAssertTrue(counter == 2, "loading")
                testCounter += 1
            case .initial(.success(_)):
                XCTAssertTrue(counter == 3, "loaded")
                testCounter += 1
            case .initial(.failure(_)):
                XCTAssertTrue(false, "should not go here")
            default:
                break
            }
            
            if (counter >= 3) {
                XCTAssertTrue(testCounter == 3, "")
            }
        }
        
        let exp = expectation(description: "yes")
        
        store.subscribe(subscriber)
        
        store.dispatch(NewsListActions.loadInitialNews())
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
        
        
    }
    
}
