//
//  TabBarItem.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

private var myContext = 0

class TabBarItem: UIButton {

    // MARK: - Properties

    var width: CGFloat = 80.0

    override var selected: Bool {
        willSet {
            self.topBorder.backgroundColor =  newValue ? UIColor.selectedStateTopBorderColor() : UIColor.normalStateTopBorderColor()
        }
    }

    lazy var topBorder: UIView = {
        let border = UIView()
        border.backgroundColor = UIColor.normalStateTopBorderColor()
        border.setTranslatesAutoresizingMaskIntoConstraints(false)
        return border
    }()

    // MARK: - Initialiers

    convenience init(title: String) {
        self.init(frame: CGRectZero)
        self.setTitle(title, forState: .Normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setBackgroundImage(UIImage.imageWithColor(UIColor.normalStateBackgroundColor()), forState: .Normal)
        setBackgroundImage(UIImage.imageWithColor(UIColor.normalStateBackgroundColor()), forState: .Highlighted)
        setBackgroundImage(UIImage.imageWithColor(UIColor.selectedStateBackgroundColor()), forState: .Selected)
        titleLabel!.font = UIFont(name: "Avenir", size: 18.0)

        let views = [
            "topBorder" : topBorder
        ]

        let metrics = [
            "borderHeight" : 5
        ]

        addSubview(topBorder)

        topBorder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topBorder(borderHeight)]", options: nil, metrics: metrics, views:views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topBorder]", options: nil, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topBorder]|", options: nil, metrics: nil, views: views))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(width, 49);
    }
}

private extension UIColor {

    class func normalStateBackgroundColor() -> UIColor {
        return UIColor(red: 0.145, green: 0.392, blue: 0.498, alpha: 1.0)
    }

    class func selectedStateBackgroundColor() -> UIColor {
        return UIColor(red: 0.047, green: 0.294, blue: 0.400, alpha: 1.0)
    }

    class func normalStateTopBorderColor() -> UIColor {
        return UIColor(red: 0.047, green: 0.294, blue: 0.400, alpha: 1.0)
    }

    class func selectedStateTopBorderColor() -> UIColor {
        return UIColor(red: 0.000, green: 0.196, blue: 0.302, alpha: 1.0)
    }
}
