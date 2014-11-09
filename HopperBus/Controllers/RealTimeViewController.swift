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
        textField.backgroundColor = UIColor(red:0.000, green:0.694, blue:0.416, alpha: 1)
        textField.tintColor = UIColor.clearColor()
        textField.inputView = self.textFieldInputView
        textField.font = UIFont(name: "Avenir-Light", size: 17.0)
        textField.setTranslatesAutoresizingMaskIntoConstraints(false)

        // UITextField Padding
        let paddingView = UIView(frame: CGRectMake(0, 0, 20, 50))
        textField.leftView = paddingView;
        textField.leftViewMode = .Always;
        textField.rightView = paddingView;
        textField.rightViewMode = .Always;
        return textField
    }()

    lazy var pickerViewToolbar: UIToolbar = {
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Bordered, target: self, action: "doneButtonClicked")
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        toolbar.items = [flex, doneButton]
        return toolbar
    }()

    lazy var pickerView: UIPickerView = {
        //let pickerView = UIPickerView(frame: CGRectMake(0, 44, self.view.frame.size.width, 180))
        let pickerView = UIPickerView(frame: CGRectMake(0, 44, self.view.frame.size.width, 220))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1)
        return pickerView
    }()

    lazy var textFieldInputView: UIView = {
        let view = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 264))
        view.addSubview(self.pickerViewToolbar)
        view.addSubview(self.pickerView)
        view.backgroundColor = UIColor(red:0.145, green:0.380, blue:0.482, alpha: 1)
        return view
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(RealTimeTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        view.addSubview(textField)
        view.addSubview(tableView)
        view.backgroundColor = UIColor.whiteColor()

        textField.becomeFirstResponder()
    }

    override func updateViewConstraints() {

        if (!didSetupContraints) {

            let views = [
                "mapView": mapView,
                "textField": textField,
                "tableView": tableView
            ]

            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[mapView]|", options: nil, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textField]|", options: nil, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tableView]|", options: nil, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView(350)][textField(55)][tableView]|", options: nil, metrics: nil, views: views))
        }

        super.updateViewConstraints()
    }

    func doneButtonClicked() {
        textField.text = viewModel.textForSelectedRouteAndStop()
        textField.resignFirstResponder()
    }
}

extension RealTimeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as RealTimeTableViewCell
        return cell
    }
}


extension RealTimeViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        return MKTileOverlayRenderer(overlay: overlay)
    }

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: false)
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