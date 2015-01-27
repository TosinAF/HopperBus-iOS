//
//  AboutViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum AboutSection {
    case Team, DISE, Apps
}

class BaseAboutViewController: UIViewController {
    var type: AboutSection {
        return .Team
    }
}

class AboutViewController: UIViewController {

    // MARK: - Properties

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "About The Developers - DISE"
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
        let vc: UIViewController = AboutTeamViewController()
        pageViewController.setViewControllers([vc], direction:  UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        return pageViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(titleLabel)
        view.addSubview(dismissButton)

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
            "containerView": pageViewController.view
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-15-[titleLabel]-20-[dismissButton(30)]-10-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[dismissButton(30)]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[titleLabel]-20-[containerView]-20-|", options: nil, metrics: nil, views: views))
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
}

