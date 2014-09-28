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

    var routeViewModelContainer = RouteViewModelContainer()

    //var currentRouteViewModel: RouteViewModel = self.routeViewModels[self.currentRouteType.toRaw() - 1]
    //lazy var routeViewModel: RouteViewModel = RouteViewModel(type: HopperBusRoutes.HB903)

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

        let name = routeViewModel.nameForStop(indexPath.row)
        let (time1, time2) = routeViewModel.timesForStop(indexPath.row)

        cell.titleLabel.text = name
        cell.timeLabel.text = time1
        cell.timeLabel2.text = time2
        cell.isLastCell = indexPath.row == routeViewModel.numberOfStopsForCurrentRoute() - 1 ? true : false

        return cell
    }

    // Delegate

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}

// MARK: - TabBarDelegate Methods

extension RouteViewController: TabBarDelegate {

    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int) {
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
