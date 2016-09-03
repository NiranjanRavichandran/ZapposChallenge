//
//  ConnectionManager.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import Foundation

class ConnectionManager: NSObject {
    
    static let sharedManager: ConnectionManager = ConnectionManager()
    
    func get(url: String, onSuccess success: (AnyObject)-> Void, onError errorHandler: ()-> Void) {
        
        if let urlObject = NSURL(string: url) {
            
            let request = NSMutableURLRequest(URL: urlObject)
            request.HTTPMethod = "GET"
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfig.timeoutIntervalForRequest = 10
            
            let session = NSURLSession(configuration: sessionConfig)
            
            session.dataTaskWithRequest(request, completionHandler: { (responseData, urlResponse, responseError) in
                
                if responseError == nil {
                    do {
                        let parsed: AnyObject = try NSJSONSerialization.JSONObjectWithData(responseData!, options: .AllowFragments)
                            success(parsed)
                        } catch {
                            NSLog("Could not parse JSON")
                            errorHandler()
                    }
                }
            }).resume()
            
        }else {
            NSLog("Invalid URL...")
            errorHandler()
        }
    }
}