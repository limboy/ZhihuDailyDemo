//
//  ResultModel.swift
//  ZhihuDaily
//
//  Created by limboy on 10/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation

enum LoadingType {
    case initial, refresh, more
}

enum LoadingStatus: Equatable {
    case none
    case loading
    case loaded
    case failure(Error)
    
    static func ==(lhs: LoadingStatus, rhs: LoadingStatus) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        default:
            return false
        }
    }
}

struct ResultModel<T> {
    var loadingStatus: LoadingStatus = .none
    var loadingType: LoadingType = .initial
    
    var previousItems = [T]()
    var currentItems = [T]()
}
