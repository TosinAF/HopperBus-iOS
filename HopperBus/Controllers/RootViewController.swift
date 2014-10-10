//
//  RootViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 09/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    // MARK: - Properties

    let LastViewedRouteKey = "LastViewedRoute"
    let routeViewModelContainer = RouteViewModelContainer()

    var initialRouteType: HopperBusRoutes {
        var route: HopperBusRoutes = HopperBusRoutes.HB903
            if let lastViewedRoute = NSUserDefaults.standardUserDefaults().objectForKey(LastViewedRouteKey) as? Int {
                route = HopperBusRoutes.fromRaw(lastViewedRoute)!
            }
            return route
    }

    lazy var currentRouteType: HopperBusRoutes = self.initialRouteType

    lazy var viewControllers: [RouteViewController] = {
        var vcs = [RouteViewController]()
        for type in HopperBusRoutes.allCases {
            let routeViewModel = self.routeViewModelContainer.routeViewModel(type)
            let rvc = RouteViewController(type: type, routeViewModel: routeViewModel)
            vcs.append(rvc)
        }
        return  vcs
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var tabBar: TabBar = {
        let tabBarOptions: [String: AnyObject] = ["tabBarItemCount" : 4, "titles" : ["901","902","903","904"]]
        let tabBar =  TabBar(options:tabBarOptions)
        tabBar.delegate = self
        tabBar.setSelectedIndex(self.initialRouteType.toRaw())
        tabBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tabBar
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOPPER BUS"

        let infoButtonImage = UIImage(named: "infoButton")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: infoButtonImage, style: .Done, target: self, action:"onInfoButtonTap")

        let mapButtonImage = UIImage(named: "mapButton")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: mapButtonImage, style: .Done, target: self, action: "onMapButtonTap")

        view.addSubview(containerView)
        view.addSubview(tabBar)

        let views = [
            "tabBar": tabBar,
            "containerView": containerView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView][tabBar]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tabBar]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[containerView]|", options: nil, metrics: nil, views: views))

        let vc = viewControllers[currentRouteType.toRaw()]
        addChildViewController(vc)
        //vc.tableView.contentInset = UIEdgeInsetsMake(0, 0.0, 64.0, 0.0)
        containerView.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
    }

    // MARK: - Actions

    func onMapButtonTap() {
        let mapViewController = MapViewController()
        mapViewController.modalPresentationStyle = .Custom
        mapViewController.transitioningDelegate = self
        presentViewController(mapViewController, animated: true, completion:nil)
    }

    func onInfoButtonTap() {
        println("Info Buttton Tapped")
    }

    // MARK: - AppDelegate Methods

    func saveCurrentRoute() {
        NSUserDefaults.standardUserDefaults().setObject(currentRouteType.toRaw(), forKey: LastViewedRouteKey)
    }
}

// MARK: - TabBar Delegate

extension RootViewController: TabBarDelegate {
    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int) {
        if currentRouteType.toRaw() == index { return }

        let fromVC = viewControllers[currentRouteType.toRaw()]
        let toVC = viewControllers[index]

        fromVC.willMoveToParentViewController(nil)
        addChildViewController(toVC)
        fromVC.view.removeFromSuperview()
        fromVC.removeFromParentViewController()
        //fromVC.tableView.contentInset = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0)
        //toVC.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0)
        self.containerView.addSubview(toVC.view)

        self.currentRouteType = HopperBusRoutes.fromRaw(index)!
    }
}

// MARK: - Transitioning Delegate

extension RootViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMapViewController()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMapViewController()
    }
}
