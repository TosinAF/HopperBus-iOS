//
//  ViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {

    // MARK: - Properties

    let LastViewedRouteKey = "LastViewedRoute"
    let routeViewModelContainer = RouteViewModelContainer()

    var animTranslationStart: CGPoint!
    var animTranslationFinish: CGPoint!

    var dataSource: TableDataSource!

    var initialRouteType: HopperBusRoutes {
        var route: HopperBusRoutes = HopperBusRoutes.HB903
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

    lazy var tableView: TableView = {
        let tableView = TableView()
        tableView.delegate = self
        tableView.doubleTapDelegate = self
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 20.0, 0.0);
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.registerClass(StopTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(StopTimesTableViewCell.self, forCellReuseIdentifier: "dropdown")
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

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOPPER BUS"

        let infoButtonImage = UIImage(named: "infoButton")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: infoButtonImage, style: .Done, target: nil, action:nil)

        let mapButtonImage = UIImage(named: "mapButton")
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

        createTableScheme()

        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 55.0;
        tableView.dataSource = dataSource
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

// MARK: - TableScheme

extension RouteViewController {

    func createTableScheme() {

        let scheme = AccordionScheme()

        scheme.reuseIdentifier = "cell"
        scheme.accordionReuseIdentifier = "dropdown"

        scheme.rowCountHandler = { () in
            let routeViewModel = self.routeViewModelContainer.routeViewModel(self.currentRouteType)
            return routeViewModel.numberOfStopsForCurrentRoute()
        }

        scheme.accordionHeightHandler = { (parentIndex) in
            let cell = StopTimesTableViewCell(frame: CGRectZero)
            let rvm = self.routeViewModelContainer.routeViewModel(self.currentRouteType)
            let times = rvm.stopTimingsForStop(rvm.idForStop(parentIndex))
            cell.times = times
            return cell.height
        }

        scheme.configurationHandler = { (c, index) in
            let cell = c as StopTableViewCell
            let rvm = self.routeViewModelContainer.routeViewModel(self.currentRouteType)

            cell.titleLabel.text = rvm.nameForStop(index)
            cell.timeLabel.text = index == rvm.stopIndex ? rvm.timeTillStop(index) : rvm.timeForStop(index)
            cell.isLastCell = index == scheme.numberOfCells - 1 ? true : false
            cell.isSelected = index == rvm.stopIndex ? true : false
            cell.height = self.currentRouteType == HopperBusRoutes.HB904 ? 65 : 55
        }

        scheme.selectionHandler = { (tableView, cell, selectedIndex) in
            let routeViewModel = self.routeViewModelContainer.routeViewModel(self.currentRouteType)
            if selectedIndex == routeViewModel.stopIndex { return }

            let animPoints = self.getAnimationTranslationPoints(tableView, selectedIndex: selectedIndex)
            (self.animTranslationStart, self.animTranslationFinish) = animPoints

            self.animateSelection()

            let oldIndexPath = NSIndexPath(forRow: routeViewModel.stopIndex , inSection: 0)
            if let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? StopTableViewCell {
                self.animatedCircleView.center = self.animTranslationStart
                self.view.addSubview(self.animatedCircleView)
                oldCell.isSelected = false
                let timeStr = routeViewModel.timeForStop(oldIndexPath.row)
                oldCell.animateTimeLabelTextChange(timeStr)
            }



            routeViewModel.stopIndex = selectedIndex
            self.routeViewModelContainer.updateScheduleIndexForRoutes()
        }

        scheme.accordionConfigurationHandler = { (c, parentIndex) in
            let cell = c as StopTimesTableViewCell
            let rvm = self.routeViewModelContainer.routeViewModel(self.currentRouteType)
            let times = rvm.stopTimingsForStop(rvm.idForStop(parentIndex))
            cell.times = times
        }
        
        scheme.accordionSelectionHandler = { (c, selectedIndex) in
            return
        }
        
        dataSource = TableDataSource(scheme: scheme)
    }

    func getAnimationTranslationPoints(tableView: UITableView, selectedIndex: Int) -> (CGPoint!, CGPoint!) {
        let routeViewModel = self.routeViewModelContainer.routeViewModel(self.currentRouteType)
        let oldIndexPath = NSIndexPath(forRow: routeViewModel.stopIndex , inSection: 0)
        var start, finish: CGPoint

        if let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? StopTableViewCell {

            start = oldCell.convertPoint(oldCell.circleView.center, toView: view)

        } else {

            var cell: StopTableViewCell

            if selectedIndex > routeViewModel.stopIndex {
                // Animation Going Down
                let indexPath = tableView.indexPathsForVisibleRows()![1] as NSIndexPath
                cell = tableView.cellForRowAtIndexPath(indexPath)! as StopTableViewCell
            } else {
                // Animation Going Up On A Tuesday lol
                let visibleCellCount = tableView.indexPathsForVisibleRows()!.count
                let indexPath = tableView.indexPathsForVisibleRows()![visibleCellCount - 1] as NSIndexPath
                cell = tableView.cellForRowAtIndexPath(indexPath)! as StopTableViewCell
            }

            start = cell.convertPoint(cell.circleView.center, toView: self.view)
        }

        let newIndexPath = NSIndexPath(forRow: selectedIndex, inSection: 0)
        let newCell = tableView.cellForRowAtIndexPath(newIndexPath) as StopTableViewCell
        finish = newCell.convertPoint(newCell.circleView.center, toView: self.view)

        return (start, finish)
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension RouteViewController: UITableViewDelegate, TableViewDoubleTapDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let reuseIdentifier = dataSource.scheme.getReuseIdentifier(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        dataSource.scheme.handleSelection(tableView, cell: cell, withAbsoluteIndex: indexPath.row)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if dataSource.scheme.isAccordion(indexPath.row) {
            let parentIndex = dataSource.scheme.parentIndex
            return dataSource.scheme.accordionHeightHandler!(parentIndex: parentIndex)
        } else {
            return self.currentRouteType == HopperBusRoutes.HB904 ? 65 : 55
        }
    }

    func tableView(tableView: TableView, didDoubleTapRowAtIndexPath indexPath: NSIndexPath) {
        dataSource.scheme.handleDoubleTap(tableView, withAbsoluteIndex: indexPath.row)
    }
}

// MARK: - POPAnimation Delegate

extension RouteViewController: POPAnimationDelegate {

    // MARK:- Animatons

    func animateSelection() {

        let anim = createScaleAnimation("scaleDown", from: 1.0, to: 0.5)
        animatedCircleView.layer.pop_addAnimation(anim, forKey: "scaleDown")
        view.userInteractionEnabled = false
    }

    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {

        if anim.name == "scaleDown" {

            let anim = createYTranslationAnimation("yTranslate", from: animTranslationStart, to: animTranslationFinish)
            animatedCircleView.pop_addAnimation(anim, forKey: "center")

        } else if anim.name == "yTranslate" {

            let anim = createScaleAnimation("scaleUp", from: 0.5, to: 1.0)
            animatedCircleView.layer.pop_addAnimation(anim, forKey: "scaleUp")

        } else {

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

    func createScaleAnimation(name: String, from start: CGFloat, to finish: CGFloat) -> POPSpringAnimation {
        let routeScaleXYAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        routeScaleXYAnim.name = name
        routeScaleXYAnim.delegate = self
        routeScaleXYAnim.springBounciness = 5
        routeScaleXYAnim.springSpeed = 18
        routeScaleXYAnim.fromValue = NSValue(CGSize: CGSizeMake(start, start))
        routeScaleXYAnim.toValue = NSValue(CGSize: CGSizeMake(finish, finish))
        return routeScaleXYAnim
    }

    func createYTranslationAnimation(name: String, from start: CGPoint, to final: CGPoint) -> POPBasicAnimation {
        let yTranslationAnimation = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        yTranslationAnimation.name = name
        yTranslationAnimation.delegate = self
        yTranslationAnimation.fromValue = NSValue(CGPoint: start)
        yTranslationAnimation.toValue = NSValue(CGPoint: final)
        return yTranslationAnimation
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
