//
//  LiveBusTimesView.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 09/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class UpcomingBusTimesView: UIView {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Next Bus Times"
        label.font = UIFont(name: "Avenir-Light", size: 15.0)
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(services: [RealTimeService]) {
        super.init(frame: CGRectZero)

        var views: [String: UIView] = [
            "titleLabel": titleLabel
        ]

        for (i, service) in services.enumerate() {
            let view = ServiceView()
            view.timeTillLabel.text = service.minutesTill
            view.routeLabel.text = service.busService
            if Int(service.minutesTill) == 1 { view.minsLabel.text = "minute"}
            view.translatesAutoresizingMaskIntoConstraints = false
            views["view\(i + 1)"] = view
            addSubview(view)
        }

        if !iPhone4S && !iPhone5 {
            //let topMargin = iPhone5 ? 15 : 30
            addSubview(titleLabel)
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[titleLabel]", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleLabel]|", options: [], metrics: nil, views: views))
        }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view1]|", options: [], metrics: nil, views: views))

        var hConstraint = "|[view1]"
        if services.count > 1 {
            for i in 2...services.count {
                hConstraint += "[view\(i)(==view1)]"
            }
        }
        hConstraint += "|"
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hConstraint, options: [], metrics: nil, views: views))

        for i in 0..<services.count {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view\(i+1)]|", options: [], metrics: nil, views: views))
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ServiceView: UIView {

    lazy var timeTillLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Avenir-Book", size: 20)
        label.textAlignment = .Center
        label.backgroundColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1)
        label.layer.cornerRadius = 30
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var minsLabel: UILabel = {
        let label = UILabel()
        label.text = "minutes"
        label.textColor = UIColor.blackColor()
        label.font = UIFont(name: "Avenir-Book", size: 15)
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var routeLabel: UILabel = {
        let label = UILabel()
        label.text = "901"
        label.textColor = UIColor.blackColor()
        label.font = UIFont(name: "Avenir-Book", size: 14)
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: CGRectZero)
        addSubview(timeTillLabel)
        addSubview(minsLabel)
        addSubview(routeLabel)

        self.setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        let centerOffset: CGFloat = iPhone4S || iPhone5 ? -35.0 : -15.0

        let views = [
            "timeTillLabel": timeTillLabel,
            "minsLabel": minsLabel,
            "routeLabel": routeLabel
        ]

        timeTillLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[timeTillLabel(60)]", options: [], metrics: nil, views: views))
        timeTillLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[timeTillLabel(60)]", options: [], metrics: nil, views: views))

        addConstraint(NSLayoutConstraint(item: timeTillLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: timeTillLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: centerOffset))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[timeTillLabel]-5-[minsLabel]-5-[routeLabel]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[minsLabel]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[routeLabel]|", options: [], metrics: nil, views: views))

        super.updateConstraints()
    }
}
