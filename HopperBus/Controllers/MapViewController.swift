//
//  MapViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 16/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

enum UniversityCampusMaps: Int {
    case SuttonBonnigton = 0, JubileeCampus, UniversityPark

    var resourceURL: NSURL? {

        let pdfTitles = [
            "SuttonBoningtonCampus",
            "JubileeCampus",
            "UniversityParkCampus"
        ]

        return NSBundle.mainBundle().URLForResource(pdfTitles[toRaw()], withExtension: "pdf")
    }
}

class MapViewController: UIViewController {

    var currentMap: UniversityCampusMaps = .UniversityPark

    lazy var pdfView: JCTiledPDFScrollView = {
        let scrollView = JCTiledPDFScrollView(frame: CGRectZero, URL: self.currentMap.resourceURL)
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)

        let views = [
            "pdfView": pdfView
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[pdfView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pdfView]|", options: nil, metrics: nil, views: views))

    }
}
