//
//  StopTimesTableViewCell.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 06/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class StopTimesTableViewCell: UITableViewCell {

    var times: Times? {
        willSet(timesVar) {
            let t = timesVar!
            titleLabel.text = "TERM TIME"
            textView.text = t.termTime.flattenToString()
            currentTimeIndicatorHConstraint?.constant = -1
            calculateHeight()

            if let s = t.saturdays {
                buttonsArray[1].enabled = true
            }

            if let h = t.holidays {
                buttonsArray[2].enabled = true
            }
        }
    }

    lazy var headerView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 14)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    var buttonsArray = [UIButton]()

    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.scrollEnabled = false
        textView.selectable = false
        textView.layoutManager.delegate = self
        textView.font = UIFont(name: "Avenir", size: 14)
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textView
    }()

    lazy var textViewHeightConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.textView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
    }()

    lazy var heightConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.contentView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
    }()

    lazy var currentTimeIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.blackColor()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    var currentTimeIndicatorHConstraint: NSLayoutConstraint?

    var height: CGFloat = 150.0

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None

        contentView.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)
        textView.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)

        createButtons()
        layoutViews()

        updateConstraints()
    }

    func createButtons() {

        let buttonTitles = ["TT", "SAT", "HOL"]

        for (i, title) in enumerate(buttonTitles) {
            let button = UIButton()
            button.tag = i
            button.enabled = false
            button.setTitle(title, forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.setTitleColor(UIColor.grayColor(), forState: .Disabled)
            button.titleLabel!.font = UIFont(name: "Avenir-Medium", size: 14)
            button.addTarget(self, action: "onButtonTap:", forControlEvents: .TouchUpInside)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            headerView.addSubview(button)
            buttonsArray.append(button)
        }

        buttonsArray[0].enabled = true
    }

    func layoutViews() {

        headerView.addSubview(titleLabel)
        headerView.addSubview(currentTimeIndicator)

        contentView.addSubview(headerView)
        contentView.addSubview(textView)

        let views = [
            "indicator": currentTimeIndicator,
            "termTimeButton": buttonsArray[0],
            "saturdayButton": buttonsArray[1],
            "holidayButton": buttonsArray[2],
            "titleLabel": titleLabel,
            "headerView": headerView,
            "textView": textView,
        ]

        currentTimeIndicator.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[indicator(5)]", options: nil, metrics: nil, views: views))
        currentTimeIndicator.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator(5)]", options: nil, metrics: nil, views: views))

        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-23-[titleLabel]", options: nil, metrics: nil, views: views))
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[termTimeButton]", options: nil, metrics: nil, views: views))
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[termTimeButton]-10-[saturdayButton]-10-[holidayButton]-28-|", options: .AlignAllCenterY, metrics: nil, views: views))
        headerView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: buttonsArray[0], attribute: .CenterY, multiplier: 1.0, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: currentTimeIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: buttonsArray[0], attribute: .CenterY, multiplier: 1.0, constant: 13))

        currentTimeIndicatorHConstraint = NSLayoutConstraint(item: currentTimeIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: buttonsArray[0], attribute: .CenterX, multiplier: 1.0, constant: -1)

        headerView.addConstraint(currentTimeIndicatorHConstraint!)

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[headerView]|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerView(35)]-8-[textView]", options: nil, metrics: nil, views: views))

        let textViewMargins = [
            "leftMargin": 18,
            "rightMargin": 16
        ]

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(leftMargin)-[textView]-(rightMargin)-|", options: nil, metrics: textViewMargins, views: views))

        contentView.addConstraint(textViewHeightConstraint)
        contentView.addConstraint(heightConstraint)
    }

    // MARK: - Actions

    func onButtonTap(sender: AnyObject) {
        let button = sender as UIButton

        let currentTimeIndicatorAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        currentTimeIndicatorAnim.springBounciness = 1
        currentTimeIndicatorAnim.springSpeed = 1

        switch button.tag {
            case 0:
                textView.text = times!.termTime.flattenToString()
                titleLabel.text = "TERM TIME"
                currentTimeIndicatorAnim.toValue = -1
            case 1:
                textView.text = times!.saturdays!.flattenToString()
                titleLabel.text = "SATURDAYS"
                currentTimeIndicatorAnim.toValue = 40
            case 2:
                textView.text = times!.holidays!.flattenToString()
                titleLabel.text = "HOLIDAYS"
                currentTimeIndicatorAnim.toValue = 80
            default:
                textView.text = times!.termTime.flattenToString()
                titleLabel.text = "TERM TIME"
                currentTimeIndicatorAnim.toValue = -1
        }

        currentTimeIndicatorHConstraint!.pop_addAnimation(currentTimeIndicatorAnim, forKey: "constantAnimation")
    }

    func calculateHeight() {
        // Beware of magic number here - width of textview
        let sizeThatFitsTextView = textView.sizeThatFits(CGSizeMake(286, 300000))
        textViewHeightConstraint.constant = ceil(sizeThatFitsTextView.height)
        heightConstraint.constant = 60 + ceil(sizeThatFitsTextView.height)
        height =  60 + ceil(sizeThatFitsTextView.height)
    }
}

extension StopTimesTableViewCell: NSLayoutManagerDelegate {

    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}
