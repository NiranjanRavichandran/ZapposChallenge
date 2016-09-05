//
//  PhotoViewController.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIViewControllerTransitioningDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var imageURL: String?
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        //Scroll view set up
        scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        self.view.addSubview(scrollView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.center = self.view.center
        imageView = UIImageView(frame: scrollView.bounds)
        imageView.contentMode = .ScaleAspectFit
        scrollView.addSubview(imageView)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "close.png"), style: .Done, target: self, action: #selector(self.dismissView))
        self.navigationItem.leftBarButtonItem = closeButton
        
        let favButton = UIBarButtonItem(image: UIImage(named: "star.png"), style: .Plain, target: self, action: #selector(self.addFavorite))
        let moreButton = UIBarButtonItem(image: UIImage(named: "more.png"), style: .Plain, target: self, action: #selector(self.showActions))
        self.navigationItem.rightBarButtonItems = [moreButton, favButton]
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
    
    func addFavorite() {
        
    }
    
    func showActions() {
        
        let moreOptions = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        moreOptions.addAction(UIAlertAction(title: "Save 💾", style: .Default, handler: { _ in
           //Saving image to camera roll
            if let imageToSave = self.imageView.image {
                self.activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(PhotoViewController.showSaveSuccess(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
        }))
        moreOptions.addAction(UIAlertAction(title: "Share 📲", style: .Default, handler: { _ in
            //Share image through other apps
            
            let textToShare = "Wallpaper Zapper is cool 😎"
            if let image = self.imageView.image {
                let objectsToShare = [image, textToShare]
                let activity = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activity.popoverPresentationController?.delegate = self
                
                self.presentViewController(activity, animated: true, completion: { 
                    //Handle completion
                })
            }
            
        }))
        
        //To show popovers on iPads instead of action sheets
        if let optionsPopover = moreOptions.popoverPresentationController {
            moreOptions.view.layoutIfNeeded()
            optionsPopover.delegate = self
        }
        
        self.presentViewController(moreOptions, animated: true, completion: nil)
    }
    
    func showSaveSuccess(imageSaved: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        
        self.activityIndicator.stopAnimating()
     
        if error == nil {
            
            Utility.showSuccess(showForSuccess: true, completion: { 
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        }else {
            Utility.showSuccess(showForSuccess: false, completion: {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            })
        }
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
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.frame = UIScreen.mainScreen().bounds
        imageView.frame = self.scrollView.bounds
    }
    
    //Centering the imageview on zoom
    func centerImageView() {
        let boundSize = scrollView.bounds.size
        var imageFrame = imageView.frame
        
        if imageFrame.width < boundSize.width {
            imageFrame.origin.x = (boundSize.width - imageFrame.size.width) / 2.0
        }else {
            imageFrame.origin.x = 0
        }
        
        if imageFrame.height < boundSize.height {
            imageFrame.origin.y = (boundSize.height - imageFrame.size.height) / 2.0
        }else {
            imageFrame.origin.y = 0
        }
        
        self.imageView.frame = imageFrame
    }
    
    //MARK: - Scrollview delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerImageView()
    }
    
    //MARK: - Popover delegate
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        
        popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems?.first
    }

}
