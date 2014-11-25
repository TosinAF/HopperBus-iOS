//
//  StopTimesTableViewCell.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 10/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class StopTimesTableViewCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 14)
        label.textAlignment = .Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    var times: [String]! {
        willSet(newTimes) {
            if newTimes.count == 1 {
                timeLabels[1].text = newTimes[0]
            } else {
                for (index,time) in enumerate(newTimes) {
                    timeLabels[index].text = time
                }
            }
        }
    }

    var stopTitle: String! {
        willSet(newTitle) {
            titleLabel.text = newTitle as String
        }
    }

    var timeLabels = [UILabel]()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None

        containerView.addSubview(titleLabel)

        for i in 0..<3 {
            let label = UILabel()
            label.font = UIFont(name: "Avenir-Light", size: 14)
            label.textColor = UIColor(red: 0.631, green: 0.651, blue: 0.678, alpha: 1)
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            label.tag = i + 1
            timeLabels.append(label)
            containerView.addSubview(label)
        }

        contentView.addSubview(containerView)

        setNeedsUpdateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        for label in timeLabels {
            label.text = ""
        }
    }

    override func updateConstraints() {

        var views = [
            "titleLabel": titleLabel
        ]

        for label in timeLabels {
            views["label\(label.tag)"] = label
        }

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleLabel]|", options: nil, metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-70-[label1]-30-[label2(==label1)]-30-[label3(==label1)]-70-|", options: .AlignAllCenterY, metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[titleLabel]-20-[label1]-10-|", options: nil, metrics: nil, views: views))

        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))

        super.updateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
