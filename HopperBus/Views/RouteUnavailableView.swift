//
//  RouteUnavailableView.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

private extension HopperBusRoutes {
    var infoText: String {
        let texts = [
            "This route is not currently in service.",
            "Route 902 is unavailable on weekends.",
            "Never reach here lol",
            "Route 903 is unavailable on sundays during term time & on weekends outside of term time.",
            "Route 904 is unavailable on weekends."
        ]
        return texts[self.rawValue]
    }
}

class RouteUnavailableView: UIView {

    let routeType: HopperBusRoutes

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = self.routeType.title.uppercaseString
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = self.routeType.infoText
        label.font = UIFont(name: "Avenir-Book", size: 22.0)
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    init(type: HopperBusRoutes) {
        self.routeType = type
        super.init(frame: CGRectZero)

        addSubview(routeHeaderView)
        addSubview(infoLabel)

        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        var views = [
            "headerView": routeHeaderView,
            "infoLabel": infoLabel
        ]

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[headerView]|", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerView(70)]", options: nil, metrics: nil, views: views))

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[infoLabel]-20-|", options: nil, metrics: nil, views: views))
        addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: -50.0))

        super.updateConstraints()
    }
}
