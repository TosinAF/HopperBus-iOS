//
//  DismissMapViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 20/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import pop
import UIKit

class DismissMapTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    // Intresting stuff about custom view controller transistion
    // http://stackoverflow.com/questions/24338700/from-view-controller-disappears-using-uiviewcontrollercontexttransitioning

    let animationDuration = 0.3

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

        toVC.view.layer.cornerRadius = 0
        
        // Create POP Animations

        let routeScaleXYAnim = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        routeScaleXYAnim.toValue = NSValue(CGSize: CGSizeMake(1, 1))

        let routeTranslateYAnim = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        routeTranslateYAnim.toValue = 0

        var mapFrame = fromVC.view.frame
        mapFrame.origin.y += 60

        let mapFrameAnim = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        mapFrameAnim.springBounciness = 5
        mapFrameAnim.springSpeed = 30
        mapFrameAnim.toValue = NSValue(CGRect: mapFrame)

        // Begin Animations

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            fromVC.view.alpha = 0.0
        })

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in

            toVC.view.alpha = 1.0

            }) { (finished) -> Void in

                toVC.view.userInteractionEnabled = true
                transitionContext.completeTransition(true)

                // iOS 8 Bug ->
                // http://joystate.wordpress.com/2014/09/02/ios8-and-custom-uiviewcontrollers-transitions/
                UIApplication.sharedApplication().keyWindow!.addSubview(toVC.view)
        }

        toVC.view.layer.pop_addAnimation(routeTranslateYAnim, forKey: "transform.translation.y")
        toVC.view.layer.pop_addAnimation(routeScaleXYAnim, forKey: "transform.scale")
        fromVC.view.pop_addAnimation(mapFrameAnim, forKey: "frame");
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
}
