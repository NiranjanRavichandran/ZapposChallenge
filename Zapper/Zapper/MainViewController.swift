//
//  ViewController.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 03/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let redditAPI = "https://www.reddit.com/r/wallpapers/.json?t=week&limit=40"

    var collectionView: UICollectionView!
    var wallpaperList = [Wallpaper]()
    var favorites: [Wallpaper]?
    var segmentControl: UISegmentedControl!
    var isFavorites: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reddit Wallpapers"
        self.view.backgroundColor = UIColor.whiteColor()
        
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
        
        //Navigation bar set up
        self.navigationController?.navigationBar.barTintColor = Utility.appBaseColor
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        fetchData()
    }
    
    func fetchData() {
        ConnectionManager.sharedManager.get(redditAPI, onSuccess: { response in
            
            if let jsonData = response.getJSON() {
                if let jsonObjects = jsonData["data"]??["children"] as? [NSDictionary] {
                    for item in jsonObjects {
                        self.wallpaperList.append(Wallpaper(jsonObject: item))
                    }
                    print("$$$",self.wallpaperList.first?.actSource)
                    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let imageObject = wallpaperList[indexPath.row]
        
        ConnectionManager.sharedManager.loadImageFromURL(imageObject.thumbnailURL, onSuccess: { (imageData) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                cell.imageView.image = UIImage(data: imageData)
                cell.activitIndicator.stopAnimating()

            })
            
            }) { 
                //Hanle error
                NSLog("Could not load image")
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
    
    
}

