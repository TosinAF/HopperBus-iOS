//
//  AboutDiseViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/01/2015.
//  Copyright (c) 2015 Tosin Afolabi. All rights reserved.
//

import UIKit

class AboutDiseViewController: BaseAboutViewController {

    override var type: AboutSection {
        return .DISE
    }

    lazy var diseLogo: UIImageView = {
        let image = UIImage(named: "DISELogo")!
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var statementTextView: UITextView = {
        let textView = UITextView()
        textView.text = "DISE is an umbrella name for our group which specializes in mobile and web development. We love creating apps/websites that make a positive difference in people's lives. This Hopper Bus app is the legacy we want to leave at the University of Nottingham as we prepare to graduate in June. We hope you like it. Built for Students by Students \u{1F60C}"
        textView.textAlignment = .Justified
        textView.editable = false
        textView.scrollEnabled = false
        textView.font = UIFont(name: "Avenir-Medium", size: 16.0)
        textView.textColor = UIColor.HopperBusBrandColor()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "AboutDise"
        view.addSubview(diseLogo)
        view.addSubview(statementTextView)

        layoutViews()
    }

    func layoutViews() {

        let views = [
            "logo": diseLogo,
            "statement": statementTextView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[logo]-30-[statement]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[statement]-20-|", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: diseLogo, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: statementTextView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: statementTextView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
    }
}
