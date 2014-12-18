//
//  OnboardingContentTypeViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 15/12/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

// MARK: - Onboarding Content Type Enum

enum OnboardingContentType {
    case Route, RealTime, RouteTimes, Map

    var title: String {
        switch self {
        case .Route:
            return "ROUTE"
        case .RealTime:
            return "LIVE BUS DEPARTURES"
        case .RouteTimes:
            return "TIMES"
        case .Map:
            return "MAPS"
        }
    }

    var info: String {
        switch self {
        case .Route:
            return "Visualize your journey, tap on your stop to see the next bus time."
        case .RealTime:
            return "Potential Delays? Pick your current stop & find out how far away the bus is."
        case .RouteTimes:
            return "Plan ahead, view all times for a stop with a double tap on the stop."
        case .Map:
            return "Move Aroud, easily view detailed maps of the three campuses."
        }
    }

    var image: UIImage {
        switch self {
        case .Route:
            return UIImage(named: "RouteScreenshot")!
        case .RouteTimes:
            return UIImage(named: "RouteTimesScreenshot")!
        case .RealTime:
            return UIImage(named: "RealTimeScreenshot")!
        case .Map:
            return UIImage(named: "MapScreenshot")!
        }
    }

    static let allTypes: [OnboardingContentType] = [.Route, .RealTime, .RouteTimes, .Map]
}

// MARK: - Onboarding Content View Controller

class OnboardingContentViewController: UIViewController {

    // MARK: - Properties

    let type: OnboardingContentType

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.type.title
        label.font = UIFont(name: "Montserrat-Regular", size: 28.0)
        label.textColor = UIColor(red:0.392, green:0.871, blue:0.733, alpha: 1)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = self.type.info
        label.font = UIFont(name: "Avenir-Book", size: 17.0)
        label.textColor = UIColor.whiteColor()

        label.numberOfLines = 2
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = .Center
        return label
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: self.type.image)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return imageView
    }()

    // MARK: - Initializers

    init(type: OnboardingContentType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clearColor()
        view.addSubview(titleLabel)
        view.addSubview(infoLabel)
        view.addSubview(imageView)

        layoutSubviews()
    }

    func layoutSubviews() {

        let views = [
            "title": titleLabel,
            "info": infoLabel,
            "image": imageView
        ]

        view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-30-[info]-30-|", options: .AlignAllCenterX, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[title]-8-[info]-92-[image]", options: .AlignAllCenterX, metrics: nil, views: views))
    }
}
