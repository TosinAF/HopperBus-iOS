//
//  AboutAppsViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum APPS: Int {
    case Bricks = 0, TheNews, SUWelcomeApp, NEFS

    static let count = 4

    var name: String {
        let names = [
            "Bricks",
            "TheNews",
            "UoNSU Welcome App",
            "NEFS"
        ]
        return names[rawValue]
    }

    var desc: String {
        let descriptions = [
            "The objective is simple. Each level you must destroy all bricks but do it in style for those ludicrous high scores! ",
            "The News App is a hub for Designer News, Hacker News & Product Hunt.",
            "An app designed to maximise the experience delivered to you during your first week!",
            "This is an app guaranteed to improve the experience that the NEFS provides its members."
        ]
        return descriptions[rawValue]
    }

    var iconName: String {
        let iconNames = [
            "BricksIcon",
            "TheNewsIcon",
            "UoNSUWelcomeAppIcon",
            "NEFSIcon"
        ]
        return iconNames[rawValue]
    }
}

class AboutAppsViewController: BaseAboutViewController {

    override var type: AboutSection {
        return .Apps
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(AboutAppsTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tableView
    }()

    lazy var diseLogo: UIImageView = {
        let image = UIImage(named: "DISELogo")!
        let imageView = UIImageView(image: image)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(tableView)
        view.addSubview(diseLogo)

        layoutViews()
    }

    func layoutViews() {

        let views = [
            "tableView": tableView,
            "diseLogo": diseLogo
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[diseLogo(100)]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]-[diseLogo(33)]-20-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: diseLogo, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension AboutAppsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APPS.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as AboutAppsTableViewCell
        let app = APPS(rawValue: indexPath.row)!
        cell.name = app.name
        cell.desc = app.desc
        cell.iconName = app.iconName
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
