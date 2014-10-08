//
//  StopDetailView.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 03/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class StopDetailView: UIView {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.font = UIFont(name: "Avenir", size: 14)
        label.numberOfLines = 2
        return label
        }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.font = UIFont(name: "Avenir-Light", size: 14)
        label.textColor = UIColor(red: 0.631, green: 0.651, blue: 0.678, alpha: 1)
        label.textAlignment = .Right
        return label
        }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1)
        return view
        }()

    lazy var circleView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.backgroundColor = UIColor.whiteColor()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 7
        view.layer.borderColor = UIColor.disabledGreen().CGColor
        return view
        }()

    var isSelected: Bool = false {
        willSet(selected) {
            if selected {
                circleView.backgroundColor = UIColor.selectedGreen()
                circleView.layer.borderColor = UIColor.selectedGreen().CGColor
                timeLabel.textColor = UIColor.selectedGreen()
            } else {
                circleView.backgroundColor = UIColor.whiteColor()
                circleView.layer.borderColor = UIColor.disabledGreen().CGColor
                timeLabel.textColor = UIColor(red: 0.631, green: 0.651, blue: 0.678, alpha: 1)
            }
        }
    }

    var isLastCell: Bool = false {
        willSet {
            let constant: CGFloat = newValue ? -0.5 * self.frame.size.height : 0
            lineViewYConstraint.constant = constant
        }
    }

    lazy var lineViewYConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.lineView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0)
    }()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience override init() {
        self.init(frame: CGRectZero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(lineView)
        addSubview(circleView)

        titleLabel.text = "George Green Library"
        timeLabel.text = "12:50 pm"

        let views = [
            "timeLabel": timeLabel,
            "titleLabel": titleLabel,
            "lineView": lineView,
            "circleView": circleView,
        ]

        let metrics = [
            "margin": 6,
            "leftMargin": 16,
            "lineMargin": 14
        ]

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(leftMargin)-[timeLabel(80)]-(lineMargin)-[lineView(2)]-(lineMargin)-[titleLabel]-|", options: nil, metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(margin)-[titleLabel]-(margin)-|", options: nil, metrics: metrics, views: views))

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[lineView]", options: nil, metrics: metrics, views: views))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .CenterX, relatedBy: .Equal, toItem: lineView, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .CenterY, relatedBy: .Equal, toItem: titleLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 14))
        addConstraint(NSLayoutConstraint(item: circleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 14))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: timeLabel, attribute: .CenterY, multiplier: 1, constant: 0))

        addConstraint(lineViewYConstraint)
    }


    func animateTimeLabelTextChange(text: String) {

        let animation = CATransition();
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade;
        animation.duration = 0.15;
        timeLabel.layer.addAnimation(animation, forKey: "kCATransitionFade")

        timeLabel.text = text
    }
}
