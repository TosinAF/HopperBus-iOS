//
//  RootViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 09/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController {

    // MARK: - Properties

    let LastViewedRouteKey = "LastViewedRoute"
    var routeViewModelContainer = RouteViewModelContainer()

    var inInfoSection = false
    let infoViewController = InfoViewController()

    var initialRouteType: HopperBusRoutes {
        var route: HopperBusRoutes = HopperBusRoutes.HB903
        if let lastViewedRoute = NSUserDefaults.standardUserDefaults().objectForKey(LastViewedRouteKey) as? Int {
            route = HopperBusRoutes(rawValue: lastViewedRoute)!
        }
        return route
    }

    lazy var currentRouteType: HopperBusRoutes = self.initialRouteType

    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var viewControllers: [UIViewController] {
        return self.routeViewModelContainer.routeViewControllers
    }

    lazy var tabBar: TabBar = {
        let titles: [String] = ["901","902","LIVE","903","904"]
        let tabBar =  TabBar(titles: titles)
        tabBar.delegate = self
        tabBar.selectedIndex = self.initialRouteType.rawValue
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    // MARK: - View Lifecycle

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

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

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView][tabBar]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tabBar]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[containerView]|", options: [], metrics: nil, views: views))

        let vc = routeViewModelContainer.routeViewControllers[currentRouteType.rawValue]
        addChildViewController(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
        
        checkForDataUpdates()
    }

    // MARK: - Actions

    func onMapButtonTap() {
        let mapViewController = MapViewController()
        mapViewController.modalPresentationStyle = .Custom
        mapViewController.transitioningDelegate = self
        presentViewController(mapViewController, animated: true, completion:nil)
    }

    func onInfoButtonTap() {

        if inInfoSection { return }

        let fromVC = viewControllers[currentRouteType.rawValue]

        transition(fromVC, toVC: infoViewController)
        inInfoSection = true
    }

    // MARK: - AppDelegate Methods

    func saveCurrentRoute() {
        NSUserDefaults.standardUserDefaults().setObject(currentRouteType.rawValue, forKey: LastViewedRouteKey)
    }

    // MARK: - Utility Methods

    func transition(fromVC: UIViewController, toVC: UIViewController) {
        fromVC.willMoveToParentViewController(nil)
        addChildViewController(toVC)
        fromVC.view.removeFromSuperview()
        fromVC.removeFromParentViewController()
        self.containerView.addSubview(toVC.view)
    }
    
    func showTab(index: Int) {
        if currentRouteType.rawValue == index && inInfoSection == false { return }
        
        if index == HopperBusRoutes.HBRealTime.rawValue {
            self.title = "LIVE BUS DEPARTURES"
        } else {
            self.title = "HOPPER BUS"
        }
        
        let fromVC = inInfoSection ? infoViewController : viewControllers[currentRouteType.rawValue]
        let toVC = viewControllers[index]
        
        transition(fromVC, toVC: toVC)
        
        self.currentRouteType = HopperBusRoutes(rawValue: index)!
        inInfoSection = false
    }
    
    func getViewControllers() {
        var vcs = [UIViewController]()
        for type in HopperBusRoutes.allCases {
            if type == .HB901 {
                let routeViewModel = self.routeViewModelContainer.routeViewModel(type) as! RouteTimesViewModel
                let rtvc = RouteTimesViewController(type: type, routeViewModel: routeViewModel)
                vcs.append(rtvc)
            } else if type == .HBRealTime {
                let viewModel = self.routeViewModelContainer.routeViewModel(type) as! RealTimeViewModel
                let rtvc = RealTimeViewController(type: type, viewModel: viewModel)
                vcs.append(rtvc)
            } else {
                let routeViewModel = self.routeViewModelContainer.routeViewModel(type) as! RouteViewModel
                let rvc = RouteViewController(type: type, routeViewModel: routeViewModel)
                vcs.append(rvc)
            }
        }
    }
}

// MARK: - TabBar Delegate

extension HomeViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int) {
        showTab(index)
    }
}

// MARK: - Transitioning Delegate

extension HomeViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMapTransitionManager()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMapTransitionManager()
    }
}

// Background Download of Datastore

extension HomeViewController {
    
    func checkForDataUpdates() {
        
        let url = "https://raw.githubusercontent.com/TosinAF/HopperBus-iOS/master/HopperBus/Resources/Routes/Routes.json"
        Alamofire.request(.GET, url).response {
            (request, response, data, error) -> Void in
            
            guard let jsonData = data else {
                print("No Data")
                return
            }
            
            let json = JSON(data: jsonData)
            let version = json["version"].floatValue
            let currentVersion = NSUserDefaults.standardUserDefaults().floatForKey(kDataStoreVersion)
            
            if version > currentVersion {
                
                let p = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
                let path = p.stringByAppendingPathComponent("routeData")
                jsonData.writeToFile(path, atomically: false)
                self.routeViewModelContainer = RouteViewModelContainer()
            }
        }
    }
}
