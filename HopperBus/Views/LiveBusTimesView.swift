//
//  LiveBusTimesView.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 09/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class LiveBusTimesView: UIView {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Next Bus Times"
        label.font = UIFont(name: "Avenir-Light", size: 15.0)
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = .Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    override init() {
        super.init(frame: CGRectZero)

        let view1 = LiveBusTimeView()
        view1.timeTillLabel.text = "5"
        view1.setTranslatesAutoresizingMaskIntoConstraints(false)
        let view2 = LiveBusTimeView()
        view2.timeTillLabel.text = "7"
        view2.setTranslatesAutoresizingMaskIntoConstraints(false)
        let view3 = LiveBusTimeView()
        view3.timeTillLabel.text = "12"
        view3.setTranslatesAutoresizingMaskIntoConstraints(false)

        addSubview(titleLabel)
        addSubview(view1)
        addSubview(view2)
        addSubview(view3)

        let views = [
            "titleLabel": titleLabel,
            "view1": view1,
            "view2": view2,
            "view3": view3
        ]

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleLabel]|", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[view1][view2(==view1)][view3(==view1)]|", options: nil, metrics: nil, views: views))

        var topMargin = 30
        if iPhone5 { topMargin = 25 }
        if iPhone4S { topMargin = 15 }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(topMargin)-[titleLabel]", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view1]|", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view2]|", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view3]|", options: nil, metrics: nil, views: views))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LiveBusTimeView: UIView {

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

    override init() {
        super.init(frame: CGRectZero)
        addSubview(timeTillLabel)
        addSubview(minsLabel)

        self.setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        let views = [
            "timeTillLabel": timeTillLabel,
            "minsLabel": minsLabel
        ]

        timeTillLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[timeTillLabel(60)]", options: .AlignAllCenterY, metrics: nil, views: views))
        timeTillLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[timeTillLabel(60)]", options: .AlignAllCenterY, metrics: nil, views: views))

        addConstraint(NSLayoutConstraint(item: timeTillLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: timeTillLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: -5.0))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[timeTillLabel]-5-[minsLabel]", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[minsLabel]|", options: nil, metrics: nil, views: views))

        super.updateConstraints()
    }
}
