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

    let viewModel: RealTimeViewModel!

    var didCenterOnuserLocation = false
    var isPickerViewDisplayed = true

    lazy var locationManager: CLLocationManager = {
        let locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locManager.requestWhenInUseAuthorization()
        return locManager
    }()

    lazy var mapView: MKMapView = {
        let mapBoxOverlay = MBXRasterTileOverlay(mapID: "tosinaf.k5b76j66")
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.addOverlay(mapBoxOverlay)
        mapView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return mapView
    }()

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Pick a Route & Stop"
        textField.textAlignment = .Center
        textField.textColor = UIColor.whiteColor()
        textField.backgroundColor = UIColor.clearColor()
        textField.tintColor = UIColor.clearColor()
        textField.inputView = self.pickerViewContainer
        textField.font = UIFont(name: "Avenir-Light", size: 17.0)
        textField.delegate = self
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textField
    }()

    lazy var textFieldContainer: UIView = {
        let view = UIView()
        view.addSubview(self.textField)
        view.addSubview(self.textFieldToggleButton)
        view.backgroundColor = UIColor(red:0.000, green:0.694, blue:0.416, alpha: 1)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()

    lazy var textFieldToggleButton: UIButton = {
        let button = UIButton();
        let normalButtonImage = UIImage(named: "upButton")
        let selectedButtonImage = UIImage(named: "downButton")
        button.setImage(normalButtonImage, forState: .Normal)
        button.setImage(selectedButtonImage, forState: .Selected)
        button.addTarget(self, action: "toggleButtonClicked", forControlEvents: .TouchUpInside)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        return button
    }()

    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: CGRectMake(0, 0, self.view.frame.size.width,  0.4 * self.view.frame.size.height))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1)
        return pickerView
    }()

    lazy var pickerViewContainer: UIView = {
        let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width,  0.4 * self.view.frame.size.height))
        view.addSubview(self.pickerView)
        view.backgroundColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1)
        return view
    }()

    lazy var liveBusTimesView: LiveBusTimesView = {
        let liveBusTimesView = LiveBusTimesView()
        liveBusTimesView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return liveBusTimesView
    }()

    // MARK: - Initalizers

    init(type: HopperBusRoutes, viewModel: RealTimeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(mapView)
        view.addSubview(textFieldContainer)
        view.addSubview(liveBusTimesView)

        layoutSubviews()

        textField.becomeFirstResponder()
        textFieldToggleButton.selected = true
    }

    func layoutSubviews() {

        let views = [
            "mapView": mapView,
            "textField": textField,
            "liveView": liveBusTimesView,
            "textFieldContainer": textFieldContainer,
            "toggleButton": textFieldToggleButton
        ]


        textFieldContainer.addConstraint(NSLayoutConstraint(item: textField, attribute: .CenterX, relatedBy: .Equal, toItem: textFieldContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        textFieldContainer.addConstraint(NSLayoutConstraint(item: textField, attribute: .CenterY, relatedBy: .Equal, toItem: textFieldContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        textFieldContainer.addConstraint(NSLayoutConstraint(item: textFieldToggleButton, attribute: .CenterY, relatedBy: .Equal, toItem: textFieldContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        textFieldContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[textField(<=240)]", options: nil, metrics: nil, views: views))
        textFieldContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[toggleButton(32)]-10-|", options: nil, metrics: nil, views: views))
        textFieldContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[toggleButton(32)]", options: nil, metrics: nil, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[mapView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textFieldContainer]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[liveView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView][textFieldContainer][liveView]", options: nil, metrics: nil, views: views))

        let height = self.view.frame.size.height

        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.5 * height))
        view.addConstraint(NSLayoutConstraint(item: textFieldContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.1 * height))
        view.addConstraint(NSLayoutConstraint(item: liveBusTimesView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.35 * height))
    }

    func toggleButtonClicked() {
        if (textField.isFirstResponder()) {
            textField.text = viewModel.textForSelectedRouteAndStop()
            textField.resignFirstResponder()
            textFieldToggleButton.selected = false
        } else {
            textField.becomeFirstResponder()
            textFieldToggleButton.selected = true
        }

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
            label.textAlignment = .Center
            label.numberOfLines = 2
            label.lineBreakMode = .ByTruncatingTail
            label.autoresizingMask = .FlexibleWidth
            label.textColor = UIColor.whiteColor()
            label.font = UIFont(name: "Avenir-Book", size: 17.0)
        } else {
            label = view as UILabel
        }

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
            viewModel.selectedStopIndex = 0
        } else {
            viewModel.selectedStopIndex = row
        }

        textField.text = viewModel.textForSelectedRouteAndStop()
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return UIFont.systemFontOfSize(UIFont.systemFontSize()).lineHeight * 2 * UIScreen.mainScreen().scale
    }
}

extension RealTimeViewController: UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
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

extension RealTimeViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        return MKTileOverlayRenderer(overlay: overlay)
    }

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {

        if !didCenterOnuserLocation {
            let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: false)
            didCenterOnuserLocation = !didCenterOnuserLocation
        }
        
    }
}