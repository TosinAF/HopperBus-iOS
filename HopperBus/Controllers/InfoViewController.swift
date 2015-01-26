//
//  InfoViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

class InfoViewController: GAITrackedViewController {

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
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 64.0, 0.0);
        tableView.registerClass(InfoTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

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
        return options.count
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
        cell.titleLabel.text = options[indexPath.row]
        return cell
    }
}

