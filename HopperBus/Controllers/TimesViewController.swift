//
//  StopTimesViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class TimesViewController: UIViewController {

    var times: Times? {
        willSet(timesVar) {

            createButtons()

            let t = timesVar!
            stopLabel.text = t.stopName
            timesCategoryLabel.text = "TERM TIME"
            textView.text = t.termTime.flattenToString()

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

    lazy var dismissTapArea: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        let tap = UITapGestureRecognizer(target: self, action: "onDismissButtonTap")
        view.addGestureRecognizer(tap)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 30
        button.backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.4200)
        button.setTitle("\u{274C}", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)

        let screenWidth: CGFloat = self.view.frame.size.width
        let fontSize: CGFloat = screenWidth == 320.0 ? CGFloat(70.0) : CGFloat(80.0)
        button.titleLabel?.font = UIFont(name: "Entypo", size: fontSize)

        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "onDismissButtonTap", forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var stopLabel: UILabel = {
        let label = UILabel()
        label.text = "Library Road"
        label.font = UIFont(name: "Avenir-Medium", size: 14)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var timesCategoryLabel: UILabel = {
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
        textView.textAlignment = .Center
        textView.font = UIFont(name: "Avenir", size: 14)
        textView.backgroundColor = UIColor(red: 0.906, green: 0.914, blue: 0.918, alpha: 1.0)
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textView
    }()

    lazy var currentTimeIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.blackColor()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    var currentTimeIndicatorHConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()

        headerView.addSubview(stopLabel)
        headerView.addSubview(currentTimeIndicator)
        contentView.addSubview(headerView)
        contentView.addSubview(timesCategoryLabel)
        contentView.addSubview(textView)
        contentView.addSubview(dismissButton)
        view.addSubview(dismissTapArea)
        view.addSubview(contentView)

        addConstraints()
    }

    func addConstraints() {

        let views = [
            "indicator": currentTimeIndicator,
            "termTimeButton": buttonsArray[0],
            "saturdayButton": buttonsArray[1],
            "holidayButton": buttonsArray[2],
            "stopLabel": stopLabel,
            "category": timesCategoryLabel,
            "textView": textView,
            "headerView": headerView,
            "dismissArea": dismissTapArea,
            "dismissButton": dismissButton,
            "contentView": contentView
        ]

        currentTimeIndicator.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[indicator(5)]", options: nil, metrics: nil, views: views))
        currentTimeIndicator.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator(5)]", options: nil, metrics: nil, views: views))
        currentTimeIndicatorHConstraint = NSLayoutConstraint(item: currentTimeIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: buttonsArray[0], attribute: .CenterX, multiplier: 1.0, constant: -1)

        headerView.addConstraint(currentTimeIndicatorHConstraint!)

        let screenWidth: CGFloat = view.frame.size.width
        let stopLabelMaxWidth = screenWidth == 320.0 ? 150 : 200
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-23-[stopLabel(<=\(stopLabelMaxWidth))]", options: nil, metrics: nil, views: views))
        
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[termTimeButton]", options: nil, metrics: nil, views: views))
        headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[termTimeButton]-10-[saturdayButton]-10-[holidayButton]-28-|", options: .AlignAllCenterY, metrics: nil, views: views))
        headerView.addConstraint(NSLayoutConstraint(item: stopLabel, attribute: .CenterY, relatedBy: .Equal, toItem: buttonsArray[0], attribute: .CenterY, multiplier: 1.0, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: currentTimeIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: buttonsArray[0], attribute: .CenterY, multiplier: 1.0, constant: 13))

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[headerView]|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[headerView(35)]-25-[category]-10-[textView]", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: timesCategoryLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-12-[textView]-16-|", options: nil, metrics: nil, views: views))

        dismissButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[dismissButton(60)]", options: nil, metrics: nil, views: views))
        dismissButton.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[dismissButton(60)]", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[dismissButton]-55-|", options: nil, metrics: nil, views: views))


        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[contentView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[dismissArea]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dismissArea(130)][contentView]|", options: nil, metrics: nil, views: views))
    }

    func onDismissButtonTap() {
        dismissViewControllerAnimated(true, completion: nil);
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

    // MARK: - Actions

    func onButtonTap(sender: AnyObject) {
        let button = sender as UIButton

        let currentTimeIndicatorAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        currentTimeIndicatorAnim.springBounciness = 1
        currentTimeIndicatorAnim.springSpeed = 1

        switch button.tag {
        case 0:
            textView.text = times!.termTime.flattenToString()
            timesCategoryLabel.text = "TERM TIME"
            currentTimeIndicatorAnim.toValue = -1
        case 1:
            textView.text = times!.saturdays!.flattenToString()
            timesCategoryLabel.text = "SATURDAYS"
            currentTimeIndicatorAnim.toValue = 40
        case 2:
            textView.text = times!.holidays!.flattenToString()
            timesCategoryLabel.text = "HOLIDAYS"
            currentTimeIndicatorAnim.toValue = 80
        default:
            textView.text = times!.termTime.flattenToString()
            timesCategoryLabel.text = "TERM TIME"
            currentTimeIndicatorAnim.toValue = -1
        }

        currentTimeIndicatorHConstraint!.pop_addAnimation(currentTimeIndicatorAnim, forKey: "constantAnimation")
    }

}

extension TimesViewController: NSLayoutManagerDelegate {
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}
