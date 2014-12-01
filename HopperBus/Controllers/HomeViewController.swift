//
//  RootViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 09/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Properties

    let LastViewedRouteKey = "LastViewedRoute"
    let routeViewModelContainer = RouteViewModelContainer()

    var initialRouteType: HopperBusRoutes {
        var route: HopperBusRoutes = HopperBusRoutes.HB903
            if let lastViewedRoute = NSUserDefaults.standardUserDefaults().objectForKey(LastViewedRouteKey) as? Int {
                route = HopperBusRoutes(rawValue: lastViewedRoute)!
            }
            return route
    }

    lazy var currentRouteType: HopperBusRoutes = self.initialRouteType

    lazy var viewControllers: [UIViewController] = {
        var vcs = [UIViewController]()
        for type in HopperBusRoutes.allCases {
            if type == .HB901 {
                let routeViewModel = self.routeViewModelContainer.routeViewModel(type) as RouteTimesViewModel
                let rtvc = RouteTimesViewController(type: type, routeViewModel: routeViewModel)
                vcs.append(rtvc)
            } else if type == .HBRealTime {
                let viewModel = self.routeViewModelContainer.routeViewModel(type) as RealTimeViewModel
                let rtvc = RealTimeViewController(type: type, viewModel: viewModel)
                vcs.append(rtvc)
            } else {
                let routeViewModel = self.routeViewModelContainer.routeViewModel(type) as RouteViewModel
                let rvc = RouteViewController(type: type, routeViewModel: routeViewModel)
                vcs.append(rvc)
            }
        }
        return vcs
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var tabBar: TabBar = {
        let tabBarOptions: [String: AnyObject] = [
            "tabBarItemCount" : 5,
            "image" : "realTime",
            "titles" : ["901","902","REAL TIME","903","904"]
        ]
        let tabBar =  TabBar(options:tabBarOptions)
        tabBar.delegate = self
        tabBar.setSelectedIndex(self.initialRouteType.rawValue)
        tabBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tabBar
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOPPER BUS"

        self.automaticallyAdjustsScrollViewInsets = false

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

        let vc = viewControllers[currentRouteType.rawValue]
        addChildViewController(vc)
        vc.view.frame = containerView.bounds
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
        NSUserDefaults.standardUserDefaults().setObject(currentRouteType.rawValue, forKey: LastViewedRouteKey)
    }
}

// MARK: - TabBar Delegate

extension HomeViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int) {
        if currentRouteType.rawValue == index { return }

        if index == HopperBusRoutes.HBRealTime.rawValue {
            self.title = "LIVE BUS DEPARTURES"
        } else {
            self.title = "HOOPER BUS"
        }

        let fromVC = viewControllers[currentRouteType.rawValue]
        let toVC = viewControllers[index]

        fromVC.willMoveToParentViewController(nil)
        addChildViewController(toVC)
        fromVC.view.removeFromSuperview()
        fromVC.removeFromParentViewController()
        self.containerView.addSubview(toVC.view)

        self.currentRouteType = HopperBusRoutes(rawValue: index)!
    }
}

// MARK: - Transitioning Delegate

extension HomeViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMapTransistionManager()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMapTransistionManager()
    }
}
