//
//  LoadResult.swift
//  ZhihuDaily
//
//  Created by limboy on 11/05/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

import Foundation

enum LoadResult<T> {
    case loading
    case success(T)
    case failure(Error)
}
