//
//  ViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TabBarDelegate {

    // MARK: - Properties

    let LastViewedRouteKey = "LastViewedRoute"

    var initialRouteType : HopperBusRoutes {
        var route: HopperBusRoutes = HopperBusRoutes.HB901
        if let lastViewedRoute = NSUserDefaults.standardUserDefaults().objectForKey(LastViewedRouteKey) as? Int {
            route = HopperBusRoutes.fromRaw(lastViewedRoute)!
        }
        return route
    }

    var c: UIView?

    lazy var currentRouteType: HopperBusRoutes = self.initialRouteType

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = self.currentRouteType.title.uppercaseString
        return view
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0);
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.registerClass(StopTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    lazy var tabBar: TabBar = {
        let tabBarOptions: [String: AnyObject] = ["tabBarItemCount" : 4, "titles" : ["901","902","903","904"]]
        let tabBar =  TabBar(options:tabBarOptions)
        tabBar.delegate = self
        tabBar.setSelectedIndex(self.currentRouteType.toRaw())
        tabBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tabBar
    }()

    lazy var animatedCircleView: UIView = {
        let circleView = UIView(frame: CGRectMake(0, 0, 14, 14))
        circleView.backgroundColor = UIColor.selectedGreen()
        circleView.layer.borderColor = UIColor.selectedGreen().CGColor
        circleView.layer.cornerRadius = 7
        return circleView
    }()

    let routeViewModelContainer = RouteViewModelContainer()

    var selectedTableViewCellIndex = 0

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOPPER BUS"

        let mapButtonImage = UIImage(named: "mapButtonImage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: mapButtonImage, style: .Done, target: self, action: "onMapButtonTap")

        let x = RouteViewModel(type: .HB904)

        view.addSubview(tableView)
        view.addSubview(tabBar)

        let views = [
            "tabBar": tabBar,
            "tableView": tableView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView][tabBar]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tabBar]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
    }

    // MARK: - Actions

    func onMapButtonTap() {
        let mapViewController = MapViewController()
        mapViewController.modalPresentationStyle = .Custom
        mapViewController.transitioningDelegate = self
        presentViewController(mapViewController, animated: true, completion:nil)
    }


    // MARK: - AppDelegate Methods

    func saveCurrentRoute() {
        NSUserDefaults.standardUserDefaults().setObject(currentRouteType.toRaw(), forKey: LastViewedRouteKey)
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension RouteViewController: UITableViewDataSource, UITableViewDelegate {

    // Datasource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)
        return routeViewModel.numberOfStopsForCurrentRoute()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as StopTableViewCell
        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)

        cell.titleLabel.text = routeViewModel.nameForStop(indexPath.row)
        cell.timeLabel.text = routeViewModel.timeForStop(indexPath.row)
        cell.isLastCell = indexPath.row == routeViewModel.numberOfStopsForCurrentRoute() - 1 ? true : false
        cell.isSelected = indexPath.row == routeViewModel.currentStopIndex ? true : false

        return cell
    }

    // Delegate

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)
        if routeViewModel.currentRouteType == HopperBusRoutes.HB904 {
            return 65
        }
        return 55
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)
        if indexPath.row == routeViewModel.currentStopIndex { return }

        let oldIndexPath = NSIndexPath(forRow: routeViewModel.currentStopIndex , inSection: 0)
        let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as StopTableViewCell
        let newCell = tableView.cellForRowAtIndexPath(indexPath) as StopTableViewCell

        let current = oldCell.convertPoint(oldCell.circleView.center, toView: view)
        let final = newCell.convertPoint(newCell.circleView.center, toView: view)

        animateSelection(fromPoint: current, toPoint: final)
        oldCell.isSelected = false

        routeViewModel.currentStopIndex = indexPath.row
        routeViewModelContainer.updateScheduleIndexForRoutes()
    }

    // MARK:- Animatons

    func animateSelection(#fromPoint: CGPoint, toPoint: CGPoint) {

        let anim = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        anim.delegate = self
        anim.springBounciness = 5
        anim.springSpeed = 2
        anim.fromValue = NSValue(CGPoint: fromPoint)
        anim.toValue = NSValue(CGPoint: toPoint)

        view.addSubview(animatedCircleView)
        animatedCircleView.pop_addAnimation(anim, forKey: "center")
        view.userInteractionEnabled = false
    }
}

// MARK: - POPAnimation Delegate

extension RouteViewController: POPAnimationDelegate {

    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {

        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)
        let indexPath = NSIndexPath(forRow: routeViewModel.currentStopIndex , inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as StopTableViewCell
        cell.isSelected = true

        animatedCircleView.removeFromSuperview()
        tableView.reloadData()
        view.userInteractionEnabled = true
    }
}

// MARK: - TabBarDelegate Methods

extension RouteViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int) {
        if index == 0 { return; }
        let route = HopperBusRoutes.fromRaw(index)!
        let title = route.title
        routeHeaderView.titleLabel.text = title.uppercaseString
        currentRouteType = route
        routeViewModelContainer.updateScheduleIndexForRoutes()
        tableView.reloadData()
    }
}

// MARK: - Transitioning Delegate

extension RouteViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMapViewController()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMapViewController()
    }
}
