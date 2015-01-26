//
//  DismissTimesViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 03/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class DismissTimesTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    let animationDuration = 0.3

    // MARK: - UIViewControllerAnimatedTransitioning Methods

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()

        // Configure Container

        containerView.addSubview(fromVC!.view)
        containerView.addSubview(toVC!.view)

        // Create POP Animations

        let routeTranslateYAnim = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        routeTranslateYAnim.fromValue = toVC!.view.layer.presentationLayer().valueForKeyPath(kPOPLayerTranslationY)
        routeTranslateYAnim.toValue = 30

        fromVC!.view.layer.pop_addAnimation(routeTranslateYAnim, forKey: "transform.translation.y")

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            fromVC!.view.alpha = 0.0
            toVC!.view.alpha = 1.0
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
                UIApplication.sharedApplication().keyWindow!.addSubview(toVC!.view)
        }
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return animationDuration
    }
}

