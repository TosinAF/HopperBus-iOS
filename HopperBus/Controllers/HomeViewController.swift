//
//  ViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

enum HopperBusRoutes: Int {
    case SB901 = 0, KM902, JB903, UP904

    var title: String {
        let routeTitles = [
            "901 - Sutton Bonington",
            "902 - King's Meadow",
            "903 - Jubilee Campus",
            "904 - Royal Derby Hospital"
        ]

        return routeTitles[toRaw()]
    }
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TabBarDelegate {

    // MARK: - Properties

    let LastViewedRouteKey = "LastViewedRoute"

    var initialRoute : HopperBusRoutes {
        var route: HopperBusRoutes = HopperBusRoutes.SB901
        if let lastViewedRoute = NSUserDefaults.standardUserDefaults().objectForKey(LastViewedRouteKey) as? Int {
            route = HopperBusRoutes.fromRaw(lastViewedRoute)!
        }
        return route
    }

    lazy var currentRoute: HopperBusRoutes = self.initialRoute

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = self.currentRoute.title.uppercaseString
        return view
    }()

    lazy var tableView: UIView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.registerClass(StopTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    lazy var tabBar: TabBar = {
        let tabBarOptions: [String: AnyObject] = ["tabBarItemCount" : 4, "titles" : ["901","902","903","904"]]
        let tabBar =  TabBar(options:tabBarOptions)
        tabBar.delegate = self
        tabBar.setSelectedIndex(self.currentRoute.toRaw())
        tabBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tabBar
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hopper Bus"


        view.addSubview(tableView)
        view.addSubview(tabBar)

        let views = [
            "tabBar": tabBar,
            "tableView": tableView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView][tabBar]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tabBar]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
    }

    // MARK: - TableViewDataSource Methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as StopTableViewCell

        if (indexPath.row == 0) {

            cell.titleLabel.text = "Jubilee Campus, The Exchange"
            cell.timeLabel.text = "8:00 am"
            cell.isLastCell = false

        } else if (indexPath.row == 1) {

            cell.titleLabel.text = "George Green Library"
            cell.timeLabel.text = "8:12 am"
            cell.isLastCell = false

        } else if (indexPath.row == 2) {

            cell.titleLabel.text = "Library Road"
            cell.timeLabel.text = "8:13 am"
            cell.isLastCell = false

        } else if (indexPath.row == 3) {

            cell.titleLabel.text = "History"
            cell.timeLabel.text = "8:19 am"
            cell.isLastCell = false

        } else if (indexPath.row == 4) {

            cell.titleLabel.text = "Rutland Hall"
            cell.timeLabel.text = "8:20 am"
            cell.isLastCell = false

        } else if (indexPath.row == 5) {

            cell.titleLabel.text = "Derby Hall"
            cell.timeLabel.text = "8:21 am"
            cell.isLastCell = false

        } else if (indexPath.row == 6) {

            cell.titleLabel.text = "Lenton & Wortley Hall"
            cell.timeLabel.text = "8:22 am"
            cell.isLastCell = false

        } else if (indexPath.row == 7) {

            cell.titleLabel.text = "George Green Library"
            cell.timeLabel.text = "8:23 am"
            cell.isLastCell = false

        } else if (indexPath.row == 8) {

            cell.titleLabel.text = "East Drive"
            cell.timeLabel.text = "8:25 am"
            cell.isLastCell = false

        } else if (indexPath.row == 9) {

            cell.titleLabel.text = "Arts Center"
            cell.timeLabel.text = "8:26 am"
            cell.isLastCell = false

        }

        else if (indexPath.row == 10) {

            cell.titleLabel.text = "9 Triumph Road"
            cell.timeLabel.text = "8:38 am"
            cell.isLastCell = true

        }

        return cell
    }

    // MARK: - TableViewDelegate Methods

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }

    // MARK: - TabBarDelegate Methods

    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int) {
        let route = HopperBusRoutes.fromRaw(index)!
        let title = route.title
        routeHeaderView.titleLabel.text = title.uppercaseString
        currentRoute = route
    }

    // MARK: - AppDelegate Methods

    func saveCurrentRoute() {
        NSUserDefaults.standardUserDefaults().setObject(currentRoute.toRaw(), forKey: LastViewedRouteKey)
    }
}
