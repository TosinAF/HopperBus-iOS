//
//  AboutTableViewCell.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {

    // MARK: - Properties

    lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30.0
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

    lazy var roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-MediumOblique", size: 14)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    var imageName: String = "" {
        willSet(imageName) {
            avatar.image = UIImage(named: imageName)
        }
    }

    var name: String = "" {
        willSet(name) {
            nameLabel.text = name
        }
    }

    var role: String = "" {
        willSet(role) {
            roleLabel.text = role
        }
    }

    // MARK: - Initializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)

        setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func updateConstraints() {

        let views = [
            "avatar": avatar,
            "name": nameLabel,
            "role": roleLabel
        ]

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[avatar(60)]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[avatar]-15-[name]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[avatar]-15-[role]", options: nil, metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[avatar(60)]", options: nil, metrics: nil, views: views))
        contentView.addConstraint(NSLayoutConstraint(item: avatar, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[name]-5-[role]-20-|", options: nil, metrics: nil, views: views))

        super.updateConstraints()
    }
}
