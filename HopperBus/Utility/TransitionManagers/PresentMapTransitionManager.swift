//
//  PresentMapVCTransistion.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 19/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import pop
import UIKit

class PresentMapTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    let animationDuration = 0.3

    // MARK: - UIViewControllerAnimatedTransitioning Methods

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! MapViewController
        let containerView = transitionContext.containerView()!

        // Set Initial Contions

        var frame = containerView.bounds
        frame.origin.y += 60
        toVC.view.frame = frame
        toVC.view.alpha = 0.0

        // Configure Container

        containerView.backgroundColor = UIColor.blackColor()
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)

        // Create POP Animations

        let routeScaleXYAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        routeScaleXYAnim.springBounciness = 1
        routeScaleXYAnim.springSpeed = 1
        routeScaleXYAnim.toValue = NSValue(CGSize: CGSizeMake(0.85, 0.85))

        let routeTranslateYAnim = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
        routeTranslateYAnim.springBounciness = 1
        routeTranslateYAnim.springSpeed = 5
        routeTranslateYAnim.toValue = -7.0

        let mapFrameAnim = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        mapFrameAnim.delegate = toVC
        mapFrameAnim.springBounciness = 2
        mapFrameAnim.springSpeed = 5
        mapFrameAnim.toValue = NSValue(CGRect: containerView.bounds)

        // Begin Animations

        UIView.animateWithDuration(0.5, animations: { () -> Void in
            fromVC.view.alpha = 0.5
        })

        UIView.animateWithDuration(0.15, animations: { () -> Void in
            toVC.view.alpha = 1.0
        })

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            fromVC.view.layer.cornerRadius = 8.0
            fromVC.view.layer.masksToBounds = true;

        }) { (finished) -> Void in
            fromVC.view.userInteractionEnabled = false
            transitionContext.completeTransition(true)
        }

        fromVC.view.layer.pop_addAnimation(routeScaleXYAnim, forKey: "transform.scale")
        fromVC.view.layer.pop_addAnimation(routeTranslateYAnim, forKey: "transform.translation.y")
        toVC.view.pop_addAnimation(mapFrameAnim, forKey: "frame")
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
}
