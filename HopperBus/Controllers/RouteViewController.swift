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
        let rvm = routeViewModelContainer.routeViewModel(currentRouteType)

        cell.titleLabel.text = rvm.nameForStop(indexPath.row)


        cell.timeLabel.text = indexPath.row == rvm.stopIndex ? rvm.timeTillStop(indexPath.row) : rvm.timeForStop(indexPath.row)
        cell.isLastCell = indexPath.row == rvm.numberOfStopsForCurrentRoute() - 1 ? true : false
        cell.isSelected = indexPath.row == rvm.stopIndex ? true : false

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
        if routeViewModel.routeType == HopperBusRoutes.HB904 {
            return 65
        }
        return 55
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)
        if indexPath.row == routeViewModel.stopIndex { return }

        let oldIndexPath = NSIndexPath(forRow: routeViewModel.stopIndex , inSection: 0)

        var start: CGPoint

        if let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? StopTableViewCell {

            start = oldCell.convertPoint(oldCell.circleView.center, toView: view)

        } else {

            var cell: StopTableViewCell

            if indexPath.row > oldIndexPath.row {
                // Animation Going Down
                println("animation going down")
                let indexPath = tableView.indexPathsForVisibleRows()![1] as NSIndexPath
                cell = tableView.cellForRowAtIndexPath(indexPath)! as StopTableViewCell
            } else {
                // Animation Going Up On A Tuesday lol
                println("animation going up")
                let visibleCellCount = tableView.indexPathsForVisibleRows()!.count
                let indexPath = tableView.indexPathsForVisibleRows()![visibleCellCount - 1] as NSIndexPath
                cell = tableView.cellForRowAtIndexPath(indexPath)! as StopTableViewCell
            }

            start = cell.convertPoint(cell.circleView.center, toView: view)
        }

        let newCell = tableView.cellForRowAtIndexPath(indexPath) as StopTableViewCell
        let finish = newCell.convertPoint(newCell.circleView.center, toView: view)

        routeViewModel.stopIndex = indexPath.row

        animateSelection(from: start, to: finish)

        if let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? StopTableViewCell {
            oldCell.isSelected = false
            let timeStr = routeViewModel.timeForStop(indexPath.row)
            oldCell.animateTimeLabelTextChange(timeStr)
        }

        routeViewModelContainer.updateScheduleIndexForRoutes()
    }

    // MARK:- Animatons

    func animateSelection(from start:CGPoint, to finish: CGPoint) {

        let anim = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        anim.delegate = self
        anim.springBounciness = 5
        anim.springSpeed = 2
        anim.fromValue = NSValue(CGPoint: start)
        anim.toValue = NSValue(CGPoint: finish)

        view.addSubview(animatedCircleView)
        animatedCircleView.pop_addAnimation(anim, forKey: "center")
        view.userInteractionEnabled = false
    }
}

// MARK: - POPAnimation Delegate

extension RouteViewController: POPAnimationDelegate {

    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {

        let routeViewModel = routeViewModelContainer.routeViewModel(currentRouteType)
        let indexPath = NSIndexPath(forRow: routeViewModel.stopIndex , inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as StopTableViewCell
        let timeStr = routeViewModel.timeTillStop(indexPath.row)
        cell.isSelected = true
        cell.animateTimeLabelTextChange(timeStr)

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
