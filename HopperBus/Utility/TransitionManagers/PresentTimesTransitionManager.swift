//
//  PresentStopTimesViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class PresentTimesTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    let animationDuration = 0.5

    // MARK: - UIViewControllerAnimatedTransitioning Methods

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()

        // Set Initial Contions

        var frame = containerView.bounds
        frame.origin.y += 130
        toVC!.view.frame = frame
        toVC!.view.alpha = 0.0

        // Configure Container

        containerView.backgroundColor = UIColor.blackColor()
        containerView.addSubview(fromVC!.view)
        containerView.addSubview(toVC!.view)

        // Create POP Animations

        let routeTranslateYAnim = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
        routeTranslateYAnim.springBounciness = 1
        routeTranslateYAnim.springSpeed = 5
        routeTranslateYAnim.fromValue = fromVC!.view.layer.presentationLayer().valueForKeyPath(kPOPLayerTranslationY)
        routeTranslateYAnim.toValue = -130

        toVC!.view.layer.pop_addAnimation(routeTranslateYAnim, forKey: "transform.translation.y")

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            fromVC!.view.alpha = 0.5
            toVC!.view.alpha = 1.0
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
        }
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return animationDuration
    }
}
