//
//  ViewController.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    let redditAPI = "https://www.reddit.com/r/wallpapers/.json?t=week&limit=40"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var reachability: Reachability?

    var collectionView: UICollectionView!
    var wallpaperList = [Wallpaper]()
    var favorites: [Wallpaper]?
    var segmentControl: UISegmentedControl!
    var isFavorites: Bool = false
    var messageView: UIView!
    var messageLabel: UILabel!
    var transition = PresentingAnimator()
    var selectedCellImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.delegate = self
        self.view.backgroundColor = Utility.appBaseColor
        
        //Segment control
        segmentControl = UISegmentedControl(items: ["Top charts", "Favorites"])
        segmentControl.selectedSegmentIndex = 0
        self.navigationItem.titleView = segmentControl
        segmentControl.addTarget(self, action: #selector(self.segmentValueChanged(_:)), forControlEvents: .ValueChanged)
        
        //Collection view set up
        let flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 2, bottom: 0, right: 2)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "MainCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")

        self.view.addSubview(collectionView)
        
        //Network connectivity test
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        }catch {
            NSLog("Creating reachability failed.")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        self.fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        //Navigation bar set up
        self.navigationController?.navigationBar.barTintColor = Utility.appBaseColor
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.clipsToBounds = false
    }
    
    func reachabilityChanged(sender: NSNotification) {
        let reachability = sender.object as! Reachability
        
        if !reachability.isReachable() {
            Utility.showNetworkAlert({ 
                self.fetchData()
            })
        }else {
            self.fetchData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        invalidateFlowLayout()
    }
    
    func invalidateFlowLayout() {
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.collectionView.frame = self.view.bounds
        if messageLabel != nil {
            self.messageLabel.center = self.view.center
        }
    }
    
    
    //MARK: - Data Loading
    
    func fetchData() {
        ConnectionManager.sharedManager.get(redditAPI, onSuccess: { response in
            
            if let jsonData = response.getJSON() {
                if let jsonObjects = jsonData["data"]??["children"] as? [NSDictionary] {
                    self.wallpaperList.removeAll()
                    for item in jsonObjects {
                        self.wallpaperList.append(Wallpaper(jsonObject: item))
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                    })
                }
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
    
    func segmentValueChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            isFavorites = false
            if !collectionView.isDescendantOfView(self.view) {
                self.view.addSubview(collectionView)
            }
            self.collectionView.reloadData()
        }else {
            isFavorites = true
            if let favsData = appDelegate.appDefaults.objectForKey("favorites") as? NSData {
                favorites = NSKeyedUnarchiver.unarchiveObjectWithData(favsData) as? [Wallpaper]
            }
            
            if favorites?.count > 0 {
                if !collectionView.isDescendantOfView(self.view) {
                    self.view.addSubview(collectionView)
                }
                self.collectionView.reloadData()
            }else {
                self.collectionView.removeFromSuperview()
                self.showNoFavsView()
            }
        }
    }
    
    func showNoFavsView() {
        
        messageView = UIView(frame: self.view.bounds)
        messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        messageLabel.textColor = UIColor.darkGrayColor()
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont(name: "Helvetica", size: 20)
        messageLabel.text = "No favorites yet!"
        messageLabel.center = messageView.center
        messageView.addSubview(messageLabel)
        self.view.addSubview(messageView)
    }
    
    //MARK: - CollectionView DataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isFavorites {
            if favorites == nil {
                return 0
            }else {
                return favorites!.count
            }
            
        }else {
            return wallpaperList.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! MainCollectionCell
        var imageURL = ""
        if isFavorites {
            imageURL = favorites![indexPath.row].thumbnailURL
        }else {
            imageURL = wallpaperList[indexPath.row].thumbnailURL
        }
        
        ConnectionManager.sharedManager.loadImageFromURL(imageURL, onSuccess: { (imageData) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                cell.imageView.image = UIImage(data: imageData)
                cell.activitIndicator.stopAnimating()
                cell.imageView.contentMode = .ScaleAspectFill

            })
            
            }) { 
                //Hanle error
                dispatch_async(dispatch_get_main_queue(), { 
                    cell.imageView.image = UIImage(named: "badImage.png")
                    cell.imageView.contentMode = .ScaleAspectFit
                    cell.activitIndicator.stopAnimating()

                })
                print("####", imageURL)
                NSLog("Could not load image - Bad URL")
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width: CGFloat = (UIScreen.mainScreen().bounds.width-10)/4
        let height: CGFloat = 150
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    //MARK: - CollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedCellImage = (collectionView.cellForItemAtIndexPath(indexPath) as! MainCollectionCell).imageView
        
        let photoVC = PhotoViewController()
        if isFavorites {
            photoVC.wallpaper = favorites?[indexPath.row]
        }else {
            photoVC.wallpaper = wallpaperList[indexPath.row]
        }
        photoVC.transitioningDelegate = self
        self.navigationController?.pushViewController(photoVC, animated: true)
    }
    
    //MARK: - ViewControllerAnimated Transition
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.originFrame = selectedCellImage.superview!.convertRect(selectedCellImage.frame, toView: nil)
        transition.presenting = true
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
    
    //Mark: - NavigationController delegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .Push {
            transition.originFrame = selectedCellImage.superview!.convertRect(selectedCellImage.frame, toView: nil)
            transition.presenting = true
            return transition
        }else if operation == .Pop {
            transition.presenting = false
            return transition
        }
        return nil
    }
    
    //Mark: - ScrollView delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset : CGFloat = scrollView.contentOffset.y
        let scrollHeight : CGFloat = scrollView.frame.size.height
        
        let scrollContentSizeHeight : CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if (scrollOffset + scrollHeight) >= scrollContentSizeHeight + 100{
//            self.bottomRefreshAnimation()
            print("^^^^^^^^^^")
            
        }
    }
    
    func bottomRefreshAnimation() {
        if self.collectionView.frame.origin.y > 0 {
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.collectionView.frame.origin.y = self.collectionView.frame.origin.y - 40
                }, completion: nil)
        }
    }
    
    deinit {
        reachability?.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: ReachabilityChangedNotification,
                                                            object: reachability)
    }

}

