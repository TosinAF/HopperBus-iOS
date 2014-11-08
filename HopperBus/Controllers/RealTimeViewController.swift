//
//  RealTimeViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RealTimeViewController: UIViewController {

    var didSetupContraints = false

    let viewModel = RealTimeViewModel()

    lazy var locationManager: CLLocationManager = {
        let locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestWhenInUseAuthorization()
        return locManager
    }()

    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return mapView
    }()

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Pick a Route & Stop"
        textField.textAlignment = .Center
        textField.textColor = UIColor.whiteColor()
        textField.backgroundColor = UIColor(red:0.000, green:0.694, blue:0.416, alpha: 1)
        textField.inputView = self.textFieldInputView
        textField.font = UIFont(name: "Avenir-Light", size: 17.0)
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textField
    }()

    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: CGRectMake(0, 44, self.view.frame.size.width, 180))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor.HopperBusBrandColor()
        return pickerView
    }()

    lazy var pickerViewToolbar: UIToolbar = {
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Bordered, target: self, action: "doneButtonClicked")
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        toolbar.items = [flex, doneButton]
        return toolbar
    }()

    lazy var textFieldInputView: UIView = {
        let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 224))
        view.addSubview(self.pickerViewToolbar)
        view.addSubview(self.pickerView)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        view.addSubview(textField)
        view.backgroundColor = UIColor.whiteColor()

        textField.becomeFirstResponder()
    }

    override func updateViewConstraints() {

        if (!didSetupContraints) {

            let views = [
                "mapView": mapView,
                "textField" : textField,
            ]

            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[mapView]|", options: nil, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textField]|", options: .AlignAllCenterY, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView][textField(67)]", options: nil, metrics: nil, views: views))

            view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.5, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: 0.0))
        }

        super.updateViewConstraints()
    }

    func doneButtonClicked() {
        textField.text = viewModel.textForSelectedRouteAndStop()
        textField.resignFirstResponder()
    }
}

extension RealTimeViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return viewModel.getNumberOfRoutes()
        } else {
            return viewModel.getNumberOfStopsForCurrentRoute()
        }
    }

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? 50.0 : 220.0
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var label : UILabel
        if view == nil {
            let height = UIFont.systemFontOfSize(UIFont.systemFontSize()).lineHeight * 2 * UIScreen.mainScreen().scale
            label = UILabel(frame: CGRectMake(0, 0, 0, height))
            label.textAlignment = NSTextAlignment.Center
            label.numberOfLines = 2
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            label.font = UIFont(name: "Avenir-Book", size: 17.0)
        } else {
            label = view as UILabel
        }

        label.textColor = UIColor.whiteColor()

        if component == 0 {
            label.text = viewModel.getRoute(atIndex: row)
        } else {
            label.text = viewModel.getStopForCurrentRoute(atIndex: row)
        }

        return label;
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            viewModel.updateSelectedRoute(index: row)
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: false)
        } else {
            viewModel.selectedStopIndex = row
        }
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return UIFont.systemFontOfSize(UIFont.systemFontSize()).lineHeight * 2 * UIScreen.mainScreen().scale
    }
}

extension RealTimeViewController: CLLocationManagerDelegate {

    func locationManager(location:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        var locValue:CLLocationCoordinate2D = locationManager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // manage if permission is denied, possibly hide map?
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}