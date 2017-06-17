//
// Created by limboy on 10/05/2017.
// Copyright (c) 2017 limboy. All rights reserved.
//

import Foundation

struct NewsItem: Equatable {
    var id: NSNumber
    var images: [String] = []
    var title: String
    var hasFaved: Bool = false
    
    static func == (lhs:NewsItem, rhs:NewsItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct NewsList {
    var news: [NewsItem]?
    var date: String
}
