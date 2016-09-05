//
//  ConnectionManager.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject {
    
    static let sharedManager: ConnectionManager = ConnectionManager()
    var imageCache = NSCache()
    
    func get(url: String, onSuccess success: (NSData)-> Void, onError errorHandler: ()-> Void) {
        
        if let urlObject = NSURL(string: url) {
            
            let request = NSMutableURLRequest(URL: urlObject)
            request.HTTPMethod = "GET"
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfig.timeoutIntervalForRequest = 10
            
            let session = NSURLSession(configuration: sessionConfig)
            
            session.dataTaskWithRequest(request, completionHandler: { (responseData, urlResponse, responseError) in
                
                if responseError == nil {
                    if let _ = responseData {
                        success(responseData!)
                    }
                }else {
                    NSLog("\(responseError)")
                    errorHandler()
                }
            }).resume()
            
        }else {
            NSLog("Invalid URL...")
            errorHandler()
        }
    }
    
    func loadImageFromURL(url: String, onSuccess success: (NSData)-> Void, onError errorHandler: ()-> Void) {
        var data: NSData?
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { 
            
            data = self.imageCache.objectForKey(url) as? NSData
        }
        
        if data == nil {
            get(url, onSuccess: { (imageData) in
                //Success handler
                self.imageCache.setObject(imageData, forKey: url)
                success(imageData)
                
            }) {
                //Error handler
                errorHandler()
            }
        }else {
            success(data!)
        }
        
    }
}

