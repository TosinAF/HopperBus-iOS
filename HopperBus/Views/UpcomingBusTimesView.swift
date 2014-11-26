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
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    init(services: [RealTimeService]) {
        super.init(frame: CGRectZero)
        addSubview(titleLabel)

        var views: [String: UIView] = [
            "titleLabel": titleLabel
        ]

        for (i, service) in enumerate(services) {
            let view = ServiceView()
            view.timeTillLabel.text = service.minutesTill
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            views["view\(i + 1)"] = view
            addSubview(view)
        }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleLabel]|", options: nil, metrics: nil, views: views))
        var topMargin = 30; if iPhone5 { topMargin = 25 }; if iPhone4S { topMargin = 15 }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(topMargin)-[titleLabel]", options: nil, metrics: nil, views: views))

        if services.count == 1 {
            //addConstraint(NSLayoutConstraint(item: views["view1"]!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[view1]|", options: nil, metrics: nil, views: views))
        } else if services.count == 2 {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[view1][view2(==view1)]|", options: nil, metrics: nil, views: views))
        } else if services.count == 3 {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[view1][view2(==view1)][view3(==view1)]|", options: nil, metrics: nil, views: views))
        }

        for i in 0..<services.count {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view\(i+1)]|", options: nil, metrics: nil, views: views))
        }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view1]|", options: nil, metrics: nil, views: views))
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
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var minsLabel: UILabel = {
        let label = UILabel()
        label.text = "mins"
        label.textColor = UIColor.blackColor()
        label.font = UIFont(name: "Avenir-Book", size: 18)
        label.textAlignment = .Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var routeLabel: UILabel = {
        let label = UILabel()
        label.text = "901"
        label.textColor = UIColor.blackColor()
        label.font = UIFont(name: "Avenir-Book", size: 14)
        label.textAlignment = .Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    override init() {
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
        let views = [
            "timeTillLabel": timeTillLabel,
            "minsLabel": minsLabel,
            "routeLabel": routeLabel
        ]

        timeTillLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[timeTillLabel(60)]", options: nil, metrics: nil, views: views))
        timeTillLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[timeTillLabel(60)]", options: nil, metrics: nil, views: views))

        addConstraint(NSLayoutConstraint(item: timeTillLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: timeTillLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: -5.0))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[timeTillLabel]-5-[minsLabel]-5-[routeLabel]", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[minsLabel]|", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[routeLabel]|", options: nil, metrics: nil, views: views))

        super.updateConstraints()
    }
}
