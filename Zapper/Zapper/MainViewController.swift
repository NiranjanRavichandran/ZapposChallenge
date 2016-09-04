//
//  ViewController.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let redditAPI = "https://www.reddit.com/r/wallpapers/top.json?t=day"

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func fetchData() {
        ConnectionManager.sharedManager.get(redditAPI, onSuccess: { response in
            
            if let jsonObjects = response["data"]??["children"] as? [NSDictionary] {
                var wallpaperList = [Wallpaper]()
                for item in jsonObjects {
                    wallpaperList.append(Wallpaper(jsonObject: item))
                }
                //                print("$$$",wallpaperList.first?.thumbnailURL)
            }
            
        }) {
            
            //Handle error here
            
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: "Alert", message: "Oops! Something went wrong.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

