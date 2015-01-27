//
//  InfoViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum InfoSection: Int {
    case About = 0, AboutTheDevelopers, WiFi, RealTime, BikesOnBuses, Accessibility, CCTV

    static let count = 7

    var title: String {
        let titles = [
            "About Hopper Bus",
            "About The Developers",
            "WiFi",
            "Real Time",
            "Bikes on Buses",
            "Accessibility",
            "CCTV"
        ]
        return titles[rawValue]
    }

    var filename: String {
        let filenames = [
            "aboutUs",
            "aboutTheDeveloper",
            "wifi",
            "realTime",
            "bikesOnBuses",
            "accessibility",
            "cctv"
        ]
        return filenames[rawValue]
    }
}

class InfoViewController: GAITrackedViewController {

    // MARK: - Properties

    let options = ["About", "Wi-FI", "Real Time", "Bikes on Buses", "Accessibility", "CCTV", "About The Developers"]

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = "INFO"
        return view
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 64.0, 0.0)
        tableView.registerClass(InfoTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "infoPage"

        view.addSubview(tableView)
        tableView.frame = view.frame
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension InfoViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InfoSection.count
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as InfoTableViewCell
        let section = InfoSection(rawValue: indexPath.row)!
        cell.titleLabel.text = section.title
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionType = InfoSection(rawValue: indexPath.row)!
        let vc = sectionType == .AboutTheDevelopers ? AboutViewController() : InfoDetailViewController(type: sectionType)
        vc.modalPresentationStyle = .Custom
        vc.transitioningDelegate = self
        presentViewController(vc, animated: true, completion:nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - Transitioning Delegate

extension InfoViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentInfoTransitionManager()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissInfoTransitionManager()
    }
}

