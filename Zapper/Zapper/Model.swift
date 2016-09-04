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
    let preview: Image?
    
    init(jsonObject: NSDictionary) {
        self.id = jsonObject["data"]?["id"] as? String ?? " "
        self.thumbnailURL = jsonObject["data"]?["thumbnail"] as? String ?? " "
        self.title = jsonObject["data"]?["title"] as? String ?? " "
        self.author = jsonObject["data"]?["author"] as? String ?? " "
        self.source = jsonObject["data"]?["url"] as? String ?? " "
        if let images = jsonObject["data"]?["preview"]??["images"] as? [NSDictionary] {
            self.preview = Image(jsonObject: images.first!)
        }else {
            self.preview = nil
        }
    }
}

struct Image {
    let id: String!
    let resolutions: [Resolution]?
    let source: Resolution?
    
    init(jsonObject: NSDictionary) {
        self.id = jsonObject["id"] as? String ?? " "
        if let res = jsonObject["resolutions"] as? [NSDictionary] {
            var resols = [Resolution]()
            for item in res {
                resols.append(Resolution(jsonObject: item))
            }
            self.resolutions = resols
        }else {
            self.resolutions = nil
        }
        if let object = jsonObject["source"] as? NSDictionary {
            self.source = Resolution(jsonObject: object)
        }else {
            self.source = nil
        }
    }
}

struct Resolution {
    let height: Int!
    let width: Int!
    let url: String!
    
    init(jsonObject: NSDictionary) {
        self.height = jsonObject["height"] as? Int ?? 0
        self.width = jsonObject["width"] as? Int ?? 0
        self.url = jsonObject["url"] as? String ?? " "
    }
}