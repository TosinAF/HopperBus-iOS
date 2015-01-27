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

    lazy var descTextView: UITextView = {
        let textView = UITextView()
        let fontSize: CGFloat = iPhone6Or6Plus ? 14.0 : 12.0
        textView.textContainerInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        textView.font = UIFont(name: "Avenir-Medium", size: fontSize)
        textView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textView
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
            descTextView.text = desc
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descTextView)

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
            "desc": descTextView
        ]

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[icon(60)]-8-[desc]-|", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[icon]-10-[name]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[icon(60)]", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[name]-2-[desc]-20-|", options: nil, metrics: nil, views: views))
        
        super.updateConstraints()
    }

}
