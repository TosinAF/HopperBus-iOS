//
//  AboutAppsTableViewCell.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

class AboutAppsTableViewCell: UITableViewCell {

    // MARK: - Properties

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let fontSize: CGFloat = iPhone6Or6Plus ? 14.0 : 12.0
        label.font = UIFont(name: "Avenir-MediumOblique", size: fontSize)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var learnMoreButton: UIButton = {
        let button = UIButton.buttonWithType(.Custom) as UIButton
        button.setTitle("Learn More", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 14)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
    }()

    var iconName: String = "" {
        willSet(iconName) {
            iconImageView.image = UIImage(named: iconName)
        }
    }

    var name: String = "" {
        willSet(name) {
            nameLabel.text = name
        }
    }

    var desc: String = "" {
        willSet(desc) {
            descLabel.text = desc
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(learnMoreButton)

        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func updateConstraints() {

        let views = [
            "icon": iconImageView,
            "name": nameLabel,
            "desc": descLabel,
            "learnMore": learnMoreButton
        ]
        /*
        for (key, view) in views {
            contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        }

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[icon(60)]-10-[name]-8-[desc]-8-[learnMore]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[desc]-20-|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[icon(60)]", options: nil, metrics: nil, views: views))
        //contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[name]-2-[desc]-20-|", options: nil, metrics: nil, views: views))
        */

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[icon(60)]-13-[desc]-20-|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[icon]-13-[name]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[icon]-13-[learnMore]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[icon(60)]", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[name]-2-[desc]-2-[learnMore]-|", options: nil, metrics: nil, views: views))
        
        super.updateConstraints()
    }

}
