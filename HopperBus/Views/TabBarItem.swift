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

    var width: CGFloat = 64.0

    override var selected: Bool {
        willSet(isSelected) {
            self.topBorder.backgroundColor =  isSelected ? UIColor.topBorderColorForSelectedState() : UIColor.topBorderColorForNormalState()
        }
    }

    lazy var topBorder: UIView = {
        let border = UIView()
        border.backgroundColor = UIColor.topBorderColorForNormalState()
        border.setTranslatesAutoresizingMaskIntoConstraints(false)
        return border
    }()

    lazy var tbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return imageView
    }()

    var usingImage = false

    // MARK: - Initialiers

    convenience init(title: String) {
        self.init(frame: CGRectZero)
        self.setTitle(title, forState: .Normal)
    }

    convenience init(image: UIImage) {
        self.init(frame: CGRectZero)
        tbImageView.image = image

        addSubview(tbImageView)

        let views = [
            "imageView" : tbImageView
        ]

        tbImageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[imageView(20)]", options: nil, metrics: nil, views: views))
        tbImageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[imageView(20)]", options: nil, metrics: nil, views: views))

        addConstraint(NSLayoutConstraint(item: tbImageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: tbImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))

    setBackgroundImage(UIImage.imageWithColor(UIColor.imageTabBackgroundColorForNormalState()), forState: .Normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        setBackgroundImage(UIImage.imageWithColor(UIColor.backgroundColorForNormalState()), forState: .Normal)
        setBackgroundImage(UIImage.imageWithColor(UIColor.backgroundColorForNormalState()), forState: .Highlighted)
        setBackgroundImage(UIImage.imageWithColor(UIColor.backgroundColorForSelectedState()), forState: .Selected)
        titleLabel!.font = UIFont(name: "Montserrat", size: 18.0)

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

    class func backgroundColorForNormalState() -> UIColor {
        return UIColor(red: 0.145, green: 0.392, blue: 0.498, alpha: 1.0)
    }

    class func imageTabBackgroundColorForNormalState() -> UIColor {
        return UIColor(red: 0.145, green: 0.392, blue: 0.498, alpha: 0.9)
    }

    class func backgroundColorForSelectedState() -> UIColor {
        return UIColor(red: 0.047, green: 0.294, blue: 0.400, alpha: 1.0)
    }

    class func topBorderColorForNormalState() -> UIColor {
        return UIColor(red: 0.047, green: 0.294, blue: 0.400, alpha: 1.0)
    }

    class func topBorderColorForSelectedState() -> UIColor {
        return UIColor(red: 0.000, green: 0.196, blue: 0.302, alpha: 1.0)
    }
}
