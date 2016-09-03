//
//  Model.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import Foundation

struct Wallpaper {
    
    let id: String!
    let thumbnailURL: String!
    let title: String!
    let author: String!
    let source: String!
    
    init(jsonObject: NSDictionary) {
        self.id = jsonObject["data"]?["id"] as? String ?? " "
        self.thumbnailURL = jsonObject["data"]?["thumbnail"] as? String ?? " "
        self.title = jsonObject["data"]?["title"] as? String ?? " "
        self.author = jsonObject["data"]?["author"] as? String ?? " "
        self.source = jsonObject["data"]?["url"] as? String ?? " "
    }
}