//
//  StopTimesView.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 03/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class StopTimesView: UITableViewCell, NSLayoutManagerDelegate {

    var times: Times?

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

    lazy var termTimeButton: UIButton = {
        let button = UIButton()
        button.setTitle("TT", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel!.font = UIFont(name: "Avenir-Medium", size: 14)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
        }()

    lazy var saturdayButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAT", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel!.font = UIFont(name: "Avenir-Medium", size: 14)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
        }()

    lazy var holidayButton: UIButton = {
        let button = UIButton()
        button.setTitle("HOL", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleLabel!.font = UIFont(name: "Avenir-Medium", size: 14)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
        }()

    lazy var timesTextView: UITextView = {
        let textView = UITextView()
        textView.scrollEnabled = false
        textView.selectable = false
        textView.layoutManager.delegate = self
        textView.font = UIFont(name: "Avenir", size: 14)
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textView
        }()

    lazy var textViewHeightConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.timesTextView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200)
        }()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None

        backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)
        headerView.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)
        timesTextView.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)
        layoutViews()
    }

    func layoutViews() {

        headerView.addSubview(titleLabel)
        headerView.addSubview(termTimeButton)
        headerView.addSubview(saturdayButton)
        headerView.addSubview(holidayButton)

        contentView.addSubview(headerView)
        contentView.addSubview(timesTextView)

        let views = [
            "termTimeButton": termTimeButton,
            "saturdayButton": saturdayButton,
            "holidayButton": holidayButton,
            "titleLabel": titleLabel,
            "headerView": headerView,
            "textView": timesTextView,
        ]

        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-23-[titleLabel]", options: nil, metrics: nil, views: views))
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[termTimeButton]", options: nil, metrics: nil, views: views))
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[termTimeButton]-10-[saturdayButton]-10-[holidayButton]-28-|", options: .AlignAllCenterY, metrics: nil, views: views))

        headerView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: termTimeButton, attribute: .CenterY, multiplier: 1.0, constant: 0))

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[headerView]|", options: nil, metrics: nil, views: views))
         contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-18-[textView]-16-|", options: nil, metrics: nil, views: views))
         contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerView(30)]-8-[textView]", options: nil, metrics: nil, views: views))

        titleLabel.text = "TERM TIME"
        timesTextView.text = "19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50 19:50"
        let sizeThatFitsTextView = timesTextView.sizeThatFits(CGSizeMake(timesTextView.frame.size.width, 300000))
        //contentView.layoutIfNeeded()

        textViewHeightConstraint.constant = ceil(sizeThatFitsTextView.height)

        contentView.addConstraint(textViewHeightConstraint)
    }
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }

}
