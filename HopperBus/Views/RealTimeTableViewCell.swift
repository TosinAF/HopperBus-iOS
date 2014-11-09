//
//  RealTimeTableViewCell.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 09/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class RealTimeTableViewCell: UITableViewCell {

    lazy var routeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Avenir-Book", size: 17)
        label.textAlignment = .Center
        label.backgroundColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1)
        label.layer.cornerRadius = 25
        label.clipsToBounds = true
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Light", size: 20)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None

        contentView.addSubview(routeLabel)
        contentView.addSubview(timeLabel)

        timeLabel.text = "In 5 Mins."
        routeLabel.text = "901"

        self.setNeedsUpdateConstraints()
    }

    override func updateConstraints() {

        let views = [
            "routeLabel": routeLabel,
            "timeLabel": timeLabel
        ]

        routeLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[routeLabel(50)]", options: .AlignAllCenterY, metrics: nil, views: views))
        routeLabel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[routeLabel(50)]", options: .AlignAllCenterY, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-10-[routeLabel]-10-[timeLabel]", options: .AlignAllCenterY, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: routeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))

        super.updateConstraints()
    }
}
