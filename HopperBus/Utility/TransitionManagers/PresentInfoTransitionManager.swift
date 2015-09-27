//
//  PresentInfoTransitionManager.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import pop
import UIKit

class PresentInfoTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    let animationDuration = 0.3

    // MARK: - UIViewControllerAnimatedTransitioning Methods

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!

        // Set Initial Contions

        var frame = containerView.bounds
        frame.origin.y += 130
        toVC.view.frame = frame
        toVC.view.alpha = 0.0

        // Configure Container

        containerView.backgroundColor = .blackColor()
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)

        // Create POP Animations

        let routeTranslateYAnim = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
        routeTranslateYAnim.springBounciness = 1
        routeTranslateYAnim.springSpeed = 5
        routeTranslateYAnim.toValue = -110

        toVC.view.layer.pop_addAnimation(routeTranslateYAnim, forKey: "transform.translation.y")

        // Round Top Corners

        let cornerRadii = CGSizeMake(7.0, 7.0)
        let maskPath = UIBezierPath(roundedRect: toVC.view.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = containerView.bounds
        maskLayer.path = maskPath.CGPath

        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            fromVC.view.alpha = 0.5
            toVC.view.alpha = 1.0
            toVC.view.layer.mask = maskLayer

            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
        }
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
}
