//
//  PhotoViewController.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIViewControllerTransitioningDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var wallpaper: Wallpaper?
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    var scrollView: UIScrollView!
    var favorites: [Wallpaper]?
    var isFavorite: Bool = false
    var isFavoriteChanged: Bool = false
    var panGesture: UIPanGestureRecognizer!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    

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
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.dismissView(_:)))
        self.view.addGestureRecognizer(panGesture)
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "close.png"), style: .Done, target: self, action: #selector(self.dismissView(_:)))
        self.navigationItem.leftBarButtonItem = closeButton
        
        let favButton = UIBarButtonItem(image: UIImage(named: "star.png"), style: .Plain, target: self, action: #selector(self.addFavorite(_:)))
        let moreButton = UIBarButtonItem(image: UIImage(named: "more.png"), style: .Plain, target: self, action: #selector(self.showActions))
        self.navigationItem.rightBarButtonItems = [moreButton, favButton]
        
        if let unarchivedData = appDelegate.appDefaults.objectForKey("favorites") as? NSData {
            favorites = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData) as? [Wallpaper]
        }else {
            favorites = [Wallpaper]()
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {

        checkForFavorites()
        
        //Loading image...
        showImage()
        
        if isFavorite {
            let favButton = UIBarButtonItem(image: UIImage(named: "filled_star.png"), style: .Plain, target: self, action: #selector(self.addFavorite(_:)))
            self.navigationItem.rightBarButtonItems?.insert(favButton, atIndex: 1)
            self.navigationItem.rightBarButtonItems?.removeAtIndex(2)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if isFavoriteChanged {
            if let _ = favorites {
                let data = NSKeyedArchiver.archivedDataWithRootObject(favorites!)
                appDelegate.appDefaults.setObject(data, forKey: "favorites")
            }
        }
    }
    
    func addFavorite(sender: UIBarButtonItem) {
        var favButton: UIBarButtonItem!
        if isFavorite {
            isFavorite = false
            favButton = UIBarButtonItem(image: UIImage(named: "star.png"), style: .Plain, target: self, action: #selector(self.addFavorite(_:)))
            if let currentFav = wallpaper {
                favorites = favorites?.filter({ currentFav.id != $0.id })
            }
            
        }else{
            isFavorite = true
            favButton = UIBarButtonItem(image: UIImage(named: "filled_star.png"), style: .Plain, target: self, action: #selector(self.addFavorite(_:)))
            if let newFav = wallpaper {
                favorites?.append(newFav)
            }
        }
        
        self.navigationItem.rightBarButtonItems?.insert(favButton, atIndex: 1)
        self.navigationItem.rightBarButtonItems?.removeAtIndex(2)
        isFavoriteChanged = true
    }
    
    func checkForFavorites(){
        if let newFav = wallpaper, _ = favorites {
            if let _ = favorites?.filter({$0.id == newFav.id}).last {
                isFavorite = true
            }
        }
    }
    
    func showActions() {
        
        let moreOptions = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        moreOptions.addAction(UIAlertAction(title: "💾 Save", style: .Default, handler: { _ in
           //Saving image to camera roll
            if let imageToSave = self.imageView.image {
                self.activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(PhotoViewController.showSaveSuccess(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
        }))
        moreOptions.addAction(UIAlertAction(title: "📲 Share", style: .Default, handler: { _ in
            //Share image through other apps
            
            let textToShare = "Zapper for wallpapers is a cool app 😎"
            if let image = self.imageView.image {
                let objectsToShare = [image, textToShare]
                let activity = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activity.popoverPresentationController?.delegate = self
                activity.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeSaveToCameraRoll]
                
                self.presentViewController(activity, animated: true, completion: nil)
            }
            
        }))
        moreOptions.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
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
        if let url = wallpaper?.sourceURL {
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
    
    func dismissView(sender: AnyObject) {
        if let pan = sender as? UIPanGestureRecognizer {
            let velocity = pan.velocityInView(self.view)
            if velocity.y > 0 {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else {
            self.navigationController?.popViewControllerAnimated(true)
        }
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
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if scale == 1.0 {
            self.scrollView.panGestureRecognizer.requireGestureRecognizerToFail(panGesture)
        }
    }
    
    //MARK: - Popover delegate
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        
        popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems?.first
    }

}
