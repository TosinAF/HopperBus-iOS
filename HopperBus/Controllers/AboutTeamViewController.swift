//
//  AboutViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

enum DISE: Int {
    case Tosin = 0, Dipo, Ipalibo, Steve, Eman

    static let count = 5

    var name: String {
        let names = [
            "Tosin Afolabi",
            "Dipo Areoye",
            "Ipalibo Whyte",
            "Stephen Sowole",
            "Emmanuel Abiola"
        ]
        return names[rawValue]
    }

    var role: String {
        let roles = [
            "iOS & Web Developer, UX Designer",
            "Android Developer & Content Guru",
            "iOS & Web Developer, Designer",
            "iOS & Game Developer",
            "Android Developer & Marketing Guy"
        ]
        return roles[rawValue]
    }

    var imageName: String {
        let imageNames = [
            "tosinAfolabi.jpeg",
            "dipoAreoye.jpg",
            "ipaliboWhyte.jpeg",
            "stephenSowole.jpg",
            "emanAbiola.jpg"
        ]
        return imageNames[rawValue]
    }
}

class AboutTeamViewController: BaseAboutViewController {

    // MARK: - Properties

    override var type: AboutSection {
        return .Team
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(AboutTeamTableViewCell.self, forCellReuseIdentifier: "cell")
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

extension AboutTeamViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DISE.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as AboutTeamTableViewCell
        let dev = DISE(rawValue: indexPath.row)!
        cell.name = dev.name
        cell.role = dev.role
        cell.imageName = dev.imageName
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
}

