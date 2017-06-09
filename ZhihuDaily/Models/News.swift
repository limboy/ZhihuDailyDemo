//
// Created by limboy on 10/05/2017.
// Copyright (c) 2017 limboy. All rights reserved.
//

import Foundation

struct NewsItem {
    var id: NSNumber
    var images: [String]?
    var title: String
}

struct NewsList {
    var news: [NewsItem]?
    var date: String
}
