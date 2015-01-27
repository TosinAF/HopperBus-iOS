//
//  AboutViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum DISE: Int {
    case Tosin = 0, Ipalibo, Steve, Dipo, Eman

    static let count = 5

    var name: String {
        let names = [
            "Tosin Afolabi",
            "Ipalibo Whyte",
            "Stephen Sowole",
            "Dipo Areoye",
            "Emmanuel Matthews"
        ]
        return names[rawValue]
    }

    var role: String {
        let roles = [
            "iOS & Web Developer, UX Designer",
            "iOS & Web Developer, Designer",
            "iOS & Game Developer",
            "Android Developer & Content Guru",
            "Android Developer & Marketing Guy"
        ]
        return roles[rawValue]
    }

    var imageName: String {
        let imageNames = [
            "tosinAfolabi.jpeg",
            "ipaliboWhyte.jpeg",
            "stephenSowole.jpg",
            "dipoAreoye.jpg",
            "emanMatthews.jpg"
        ]
        return imageNames[rawValue]
    }
}

class AboutViewController: UIViewController {

    // MARK: - Properties

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "About The Developers - DISE"
        label.font = UIFont(name: "Montserrat", size: 18)
        label.textColor = UIColor.HopperBusBrandColor()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("\u{274C}", forState: .Normal)
        button.setTitleColor(UIColor.HopperBusBrandColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Entypo", size: 50.0)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "onDismissButtonTap", forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(AboutTableViewCell.self, forCellReuseIdentifier: "cell")
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

        view.addSubview(titleLabel)
        view.addSubview(dismissButton)
        view.addSubview(tableView)
        view.addSubview(diseLogo)

        layoutViews()
    }

    func layoutViews() {

        let views = [
            "titleLabel": titleLabel,
            "dismissButton": dismissButton,
            "tableView": tableView,
            "diseLogo": diseLogo
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-15-[titleLabel]-20-[dismissButton(30)]-10-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[dismissButton(30)]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[diseLogo(100)]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[titleLabel]-20-[tableView]-[diseLogo(33)]-40-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: diseLogo, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
    }

    // MARK: - Actions

    func onDismissButtonTap() {
        dismissViewControllerAnimated(true, completion: nil);
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DISE.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as AboutTableViewCell
        let dev = DISE(rawValue: indexPath.row)!
        cell.name = dev.name
        cell.role = dev.role
        cell.imageName = dev.imageName
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}

