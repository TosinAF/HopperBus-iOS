//
//  RouteTimesViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 10/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class RouteTimesViewController: GAITrackedViewController {

    // MARK: - Properties

    let routeType: HopperBusRoutes!
    let routeViewModel: RouteTimesViewModel!
    var timer: NSTimer?

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = self.routeType.title.uppercaseString
        return view
    }()

    lazy var tableView: TableView = {
        let tableView = TableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleTapDelegate = self
        tableView.separatorInset = UIEdgeInsetsZero
        if iOS8 { tableView.layoutMargins = UIEdgeInsetsZero }
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 64.0, 0.0);
        tableView.registerClass(StopTimesTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    lazy var routeUnavailableView: RouteUnavailableView = {
        let view = RouteUnavailableView(type: self.routeType)
        var frame = self.view.frame
        frame.origin.y += 64
        view.frame = frame
        return view
    }()

    // MARK: - Initalizers

    init(type: HopperBusRoutes, routeViewModel: RouteTimesViewModel) {
        self.routeType = type
        self.routeViewModel = routeViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(300, target: tableView, selector: "reloadData", userInfo: nil, repeats: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Route901"
        view.addSubview(tableView)
        tableView.frame = view.frame

        if !routeViewModel.isRouteInService() {
            tableView.alpha = 0.0
            if NSDate.isOutOfService() { routeUnavailableView.infoLabel.text = "The HopperBus is currently out of service." }
            view.addSubview(routeUnavailableView)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension RouteTimesViewController: UITableViewDelegate, UITableViewDataSource, TableViewDoubleTapDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeViewModel.numberOfStops()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as StopTimesTableViewCell
        cell.stopTitle = routeViewModel.nameForStop(atIndex: indexPath.row)
        cell.times = routeViewModel.nextThreeStopTimes(atIndex: indexPath.row)
        return cell
    }

    func tableView(tableView: TableView, didDoubleTapRowAtIndexPath indexPath: NSIndexPath) {
        let times = routeViewModel.stopTimingsForStop(atIndex: indexPath.row)
        let timesViewController = TimesViewController()
        timesViewController.times = times
        timesViewController.modalPresentationStyle = .Custom
        timesViewController.transitioningDelegate = self
        presentViewController(timesViewController, animated: true, completion:nil)
    }
}

// MARK: - Transitioning Delegate

extension RouteTimesViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTimesTransitionManager()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTimesTransitionManager()
    }
}