//
//  LoadResult.swift
//  ZhihuDaily
//
//  Created by limboy on 11/05/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation

enum ResultLoadingStatus: Equatable {
    case none
    case loading
    case loaded
    case failure(Error)
    
    static func ==(lhs: ResultLoadingStatus, rhs: ResultLoadingStatus) -> Bool {
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
