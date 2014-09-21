//
//  MapViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 16/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

enum UniversityCampusMaps: Int {
    case SuttonBonnigton = 0, UniversityPark, JubileeCampus

    var resourceURL: NSURL? {

        let pdfTitles = [
            "SuttonBoningtonCampus",
            "UniversityParkCampus",
            "JubileeCampus"
        ]

        return NSBundle.mainBundle().URLForResource(pdfTitles[toRaw()], withExtension: "pdf")
    }

    var contentCenter: CGPoint {

        let centerPoints = [
            CGPointMake(50,50),
            CGPointMake(370,300),
            CGPointMake(300,0)
        ]

        return centerPoints[toRaw()]
    }
}

class MapViewController: UIViewController, POPAnimationDelegate {

    // MARK: - Properies

    var currentMap: UniversityCampusMaps = .UniversityPark

    lazy var pdfView: JCTiledPDFScrollView = {
        return self.createPDFViewForMap(self.currentMap)
    }()

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "dismissButton")
        button.setImage(image, forState: .Normal)
        button.alpha = 0.0
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "onDismissButtonTap", forControlEvents: .TouchUpInside)
        return button
    }()

    lazy var optionsContainer: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()

        view.addSubview(dismissButton)
        view.addSubview(pdfView)
        view.addSubview(optionsContainer)

        layoutSubviews()
    }

    func layoutSubviews() {

        var views = [
            "dismissButton": dismissButton,
            "pdfView": pdfView,
            "optionsContainer": optionsContainer
        ]

        let optionTitles = ["SB", "UP", "JB"]

        for i in 0..<optionTitles.count {
            let button = UIButton()
            button.setTitle(optionTitles[i], forState: .Normal)
            button.titleLabel?.textAlignment = .Center
            button.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 18.0)
            button.tag = i
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            button.addTarget(self, action: "onOptionButtonSelected:", forControlEvents: .TouchUpInside)
            views["\(optionTitles[i])Button"] = button
            optionsContainer.addSubview(button)
        }

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-25-[dismissButton]", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[dismissButton]-20-|", options: nil, metrics: nil, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-7-[pdfView]-7-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-60-[pdfView]-50-|", options: nil, metrics: nil, views: views))

        optionsContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[SBButton]-60-[UPButton]-60-[JBButton]|", options: .AlignAllCenterY, metrics: nil, views: views))

        optionsContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[SBButton]|", options: .AlignAllCenterY, metrics: nil, views: views))

        optionsContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[optionsContainer(220)]", options: nil, metrics: nil, views: views))

        view.addConstraint(NSLayoutConstraint(item: optionsContainer, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[optionsContainer(30)]-10-|", options: nil, metrics: nil, views: views))
    }

    func createPDFViewForMap(type: UniversityCampusMaps) -> JCTiledPDFScrollView {
        let pdfView = JCTiledPDFScrollView(frame: CGRectZero, URL: type.resourceURL)
        pdfView.backgroundColor = UIColor.whiteColor()
        pdfView.setContentCenter(type.contentCenter, animated: true)
        pdfView.setTranslatesAutoresizingMaskIntoConstraints(false)
        pdfView.layer.cornerRadius = 8.0
        pdfView.layer.masksToBounds = true;
        return pdfView
    }

    // MARK: - Actions

    func onDismissButtonTap() {
        dismissViewControllerAnimated(true, completion: nil);
    }

    func onOptionButtonSelected(sender: AnyObject) {
        let button = sender as UIButton
        let map = UniversityCampusMaps.fromRaw(button.tag)

        if map != currentMap {

            UIView.animateWithDuration(0.0001, animations: { () -> Void in
                self.pdfView.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.pdfView.removeFromSuperview()
                self.pdfView = self.createPDFViewForMap(map!)
                self.view.addSubview(self.pdfView)

                var views = [
                    "pdfView": self.pdfView
                ]

                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-7-[pdfView]-7-|", options: nil, metrics: nil, views: views))
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-60-[pdfView]-50-|", options: nil, metrics: nil, views: views))

                UIView.animateWithDuration(0.0001, animations: { () -> Void in
                    self.pdfView.alpha = 1.0
                })
            })

            currentMap = map!
        }
    }

    // MARK: - POPAnimation Delegate

    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        // POP Animation used in the transistion controller
        UIView .animateWithDuration(0.15, animations: { () -> Void in
            self.dismissButton.alpha = 1.0
        })
    }
}
