//
//  PhotoViewController.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var imageURL: String?
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.center = self.view.center
        imageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        imageView.contentMode = .ScaleAspectFit
        self.view.addSubview(imageView)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "close.png"), style: .Done, target: self, action: #selector(self.dismissView))
//        self.navigationItem.leftBarButtonItem = closeButton
        print("####", imageURL)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {

        //Loading image...
        showImage()
    }
    
    func showImage() {
        if let url = imageURL {
            ConnectionManager.sharedManager.loadImageFromURL(url, onSuccess: { imageData in
                
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    self.imageView.image = UIImage(data: imageData)
                    self.activityIndicator.stopAnimating()
                    
                })
                }, onError: { 
                    //Error Handler
                    NSLog("Falied to fetc image data")
            })
        }
    }
    
    func dismissView() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        imageView.frame = UIScreen.mainScreen().bounds
    }

}
