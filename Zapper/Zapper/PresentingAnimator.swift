//
//  PresentingAnimator.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class PresentingAnimator: NSObject,  UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.3
    var presenting  = true
    var originFrame = CGRect.zero
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let photoView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let initialFrame = presenting ? originFrame : photoView.frame
        let finalFrame = presenting ? photoView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if presenting {
            photoView.transform = scaleTransform
            photoView.center = CGPoint(x: CGRectGetMidX(initialFrame), y: CGRectGetMidY(initialFrame))
            photoView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(photoView)
        
        UIView.animateWithDuration(duration, animations: { 
            photoView.transform = self.presenting ? CGAffineTransformIdentity : scaleTransform
            photoView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
            }) { _ in
                transitionContext.completeTransition(true)
                
        }
    }
}