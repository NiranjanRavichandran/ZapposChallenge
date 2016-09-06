//
//  Utility.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class Utility {
    
    //App utility methods
    
    class var appBaseColor: UIColor {
        
        return UIColor(red: 18/255, green: 17/255, blue: 23/255, alpha: 1.0)
    }
    
    class func showSuccess(showForSuccess status: Bool, completion: () -> Void ) {
        let successView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        successView.backgroundColor = UIColor.whiteColor()
        
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        messageLabel.textColor = UIColor.darkGrayColor()
        messageLabel.text = "Saved"
        var statusImageView = UIImageView(image: UIImage(named: "ok.png"))
        if !status {
            statusImageView = UIImageView(image: UIImage(named: "notOk.png"))
            messageLabel.text = "Save failed"
        }
        
        successView.addSubview(statusImageView)
        successView.addSubview(messageLabel)
        
        statusImageView.center = successView.center
        statusImageView.center.y -= 20
        successView.layer.cornerRadius = 10
        
        messageLabel.center = successView.center
        messageLabel.center.y += 20
        messageLabel.textAlignment = .Center
        
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            successView.center = keyWindow.center
            keyWindow.addSubview(successView)
            
            UIView.animateWithDuration(0.5, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
                successView.frame.size.width = 0
                successView.frame.size.height = 0
                successView.center = keyWindow.center
                messageLabel.alpha = 0
                statusImageView.alpha = 0
                }, completion: { _ in
                    
                    successView.removeFromSuperview()
                    completion()
            })
        }
    }
    
    class func showNetworkAlert(callback: () -> Void) {
        let alert = UIAlertController(title: "Network Error", message: "Please check you internet connection", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { _ in
            callback()
        }))
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            dispatch_async(dispatch_get_main_queue(), { 
                keyWindow.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
}

extension NSData {
    
    func getJSON() -> AnyObject? {
        
        do {
            let parsed = try NSJSONSerialization.JSONObjectWithData(self, options: .AllowFragments)
            return parsed
        }catch {
            NSLog("Could not parse JSON")
            return nil
        }
    }
}