//
//  AboutViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum AboutSection: Int {
    case Team = 0, DISE, Apps
    static let count = 3
}

class BaseAboutViewController: GAITrackedViewController {
    var type: AboutSection {
        return .Team
    }
}

class AboutViewController: GAITrackedViewController {

    // MARK: - Properties

    var currentIndex = 0
    var currentTitle = ""

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "About The Developers - Team"
        let fontSize: CGFloat = iPhone6Or6Plus ? 18.0 : 16.0
        label.font = UIFont(name: "Montserrat", size: fontSize)
        label.textColor = UIColor.HopperBusBrandColor()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("\u{274C}", forState: .Normal)
        button.setTitleColor(UIColor.HopperBusBrandColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Entypo", size: 50.0)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "onDismissButtonTap", forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.whiteColor()
        let vc: UIViewController = AboutTeamViewController()
        pageViewController.setViewControllers([vc], direction:  UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        return pageViewController
    }()

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = AboutSection.count
        pageControl.pageIndicatorTintColor = UIColor(red:0.157, green:0.392, blue:0.494, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red:0.392, green:0.871, blue:0.733, alpha: 1)
        pageControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "About"
        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        view.addSubview(pageControl)

        pageViewController.didMoveToParentViewController(self)
        addChildViewController(pageViewController)
        pageViewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(pageViewController.view)

        layoutViews()
    }

    func layoutViews() {

        let views = [
            "titleLabel": titleLabel,
            "dismissButton": dismissButton,
            "pageControl": pageControl,
            "containerView": pageViewController.view
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-15-[titleLabel]-20-[dismissButton(30)]-10-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-16-[pageControl]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[dismissButton(30)]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[titleLabel][pageControl]-10-[containerView]-20-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[containerView]|", options: nil, metrics: nil, views: views))
    }

    // MARK: - Actions

    func onDismissButtonTap() {
        dismissViewControllerAnimated(true, completion: nil);
    }
}

// MARK: - UIPageViewController DataSource & Delegate

extension AboutViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        let vc = viewController as BaseAboutViewController

        switch vc.type {
        case .Team:
            return nil
        case .DISE:
            return AboutTeamViewController()
        case .Apps:
            return AboutDiseViewController()
        }
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        let vc = viewController as BaseAboutViewController

        switch vc.type {
        case .Team:
            return AboutDiseViewController()
        case .DISE:
            return AboutAppsViewController()
        case .Apps:
            return nil
        }
    }

    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        let previousVC = pendingViewControllers.first as BaseAboutViewController
        currentIndex = previousVC.type.rawValue

        switch previousVC.type {
        case .Team:
            currentTitle = "About The Developers - Team"
        case .DISE:
            currentTitle = "About The Developers - DISE"
        case .Apps:
            currentTitle = "About The Developers - Apps"
        }
    }

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if completed {
            pageControl.currentPage = currentIndex
            titleLabel.text = currentTitle
        }
    }
}

