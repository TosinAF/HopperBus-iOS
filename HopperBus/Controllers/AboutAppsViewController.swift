//
//  AboutAppsViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum APPS: Int {
    case Bricks = 0, TheNews, Mumble, SUWelcomeApp, NEFS

    static let count = 5

    var name: String {
        let names = [
            "Bricks",
            "TheNews",
            "Mumble",
            "UoNSU Welcome App",
            "NEFS"
        ]
        return names[rawValue]
    }

    var desc: String {
        let descriptions = [
            "The objective is simple. Each level you must destroy all bricks but do it in style for those ludicrous high scores! ",
            "A beautiful app that gives you easy access to all the best content on startups, hacking and design.",
            "Mumble is a social media platform with a difference. It allows people to discover what is happening around them.",
            "An app designed to maximise the experience delivered to you during your first week!",
            "This is an app guaranteed to improve the experience that the NEFS provides its members."
        ]
        return descriptions[rawValue]
    }

    var iconName: String {
        let iconNames = [
            "BricksIcon",
            "TheNewsIcon",
            "MumbleIcon",
            "UoNSUWelcomeAppIcon",
            "NEFSIcon"
        ]
        return iconNames[rawValue]
    }

    var identifier: String {
        let identifiers = [
            "839576486",
            "884790249",
            "939454323",
            "915167615",
            "914515284"
        ]
        return identifiers[rawValue]
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var diseLogo: UIImageView = {
        let image = UIImage(named: "DISELogo")!
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidAppear(animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "AboutApps"
        view.addSubview(tableView)
        view.addSubview(diseLogo)

        layoutViews()
    }

    func layoutViews() {

        let views = [
            "tableView": tableView,
            "diseLogo": diseLogo
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[diseLogo(100)]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]-[diseLogo(33)]-20-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: diseLogo, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension AboutAppsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APPS.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AboutAppsTableViewCell
        let app = APPS(rawValue: indexPath.row)!
        cell.name = app.name
        cell.desc = app.desc
        cell.iconName = app.iconName
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = APPS(rawValue: indexPath.row)!
        let identifier = app.identifier

        let parameters = [
           SKStoreProductParameterITunesItemIdentifier : identifier
        ]

        let storeProductVC = SKStoreProductViewController()
        storeProductVC.delegate = self
        storeProductVC.loadProductWithParameters(parameters, completionBlock: { (result, error) -> Void in

            if (error != nil) { return }

            UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
            UINavigationBar.appearance().tintColor = UIColor.blackColor()
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont(name: "Montserrat", size: 18.0)!]

            self.presentViewController(storeProductVC, animated: true, completion: { () -> Void in

                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                UINavigationBar.appearance().barTintColor = UIColor.HopperBusBrandColor()
                UINavigationBar.appearance().tintColor = UIColor.whiteColor()
                UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Montserrat", size: 18.0)!]

            })
        })
    }
}

extension AboutAppsViewController: SKStoreProductViewControllerDelegate {

    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
