//
//  Model.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import Foundation

class Wallpaper: NSObject, NSCoding {
    
    let id: String!
    let thumbnailURL: String!
    let title: String!
    let author: String!
    let actSource: String!
    let sourceURL: String!
    
    init(jsonObject: NSDictionary) {
        self.id = jsonObject["data"]?["id"] as? String ?? " "
        self.thumbnailURL = jsonObject["data"]?["thumbnail"] as? String ?? " "
        self.title = jsonObject["data"]?["title"] as? String ?? " "
        self.author = jsonObject["data"]?["author"] as? String ?? " "
        self.actSource = jsonObject["data"]?["url"] as? String ?? " "
        if let images = jsonObject["data"]?["preview"]??["images"] as? [NSDictionary] {
            let preview = Image(jsonObject: images.first!)
            self.sourceURL = preview.source?.url ?? " "
        }else {
            self.sourceURL = " "
        }
    }
    
    init(id: String, thumbnailURL: String, title: String, author: String, actSource: String, sourceURL: String) {
        self.id = id
        self.actSource = actSource
        self.author = author
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.sourceURL = sourceURL
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let id = decoder.decodeObjectForKey("id") as? String, thumbnailURL = decoder.decodeObjectForKey("thumbnailURL") as? String, title = decoder.decodeObjectForKey("title") as? String, author = decoder.decodeObjectForKey("author") as? String, aSource = decoder.decodeObjectForKey("actSource") as? String, sourceUrl = decoder.decodeObjectForKey("sourceURL") as? String else { return nil }
        
            self.init(id: id, thumbnailURL: thumbnailURL, title: title, author: author, actSource: aSource, sourceURL: sourceUrl)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.thumbnailURL, forKey: "thumbnailURL")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.author, forKey: "author")
        aCoder.encodeObject(self.sourceURL, forKey: "sourceURL")
        aCoder.encodeObject(self.actSource, forKey: "actSource")
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





