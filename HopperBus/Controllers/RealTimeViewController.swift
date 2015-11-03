//
//  RealTimeViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit
import MapKit
import MBXMapKit
import CoreLocation
import ReachabilitySwift

class RealTimeViewController: GAITrackedViewController {

    // MARK: - Properties

    let viewModel: RealTimeViewModel
    let reachability = Reachability.reachabilityForInternetConnection()!

    var networkConnectionExists = true
    var didCenterOnuserLocation = false
    var currentStopAnnotation: MBXPointAnnotation?
    var timer: NSTimer?

    lazy var locationManager: CLLocationManager = {
        let locManager = CLLocationManager()
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
        mapView.translatesAutoresizingMaskIntoConstraints = false
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    lazy var textFieldContainer: UIView = {
        let view = UIView()
        view.addSubview(self.textField)
        view.addSubview(self.textFieldToggleButton)
        view.backgroundColor = UIColor(red:0.000, green:0.694, blue:0.416, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var textFieldToggleButton: UIButton = {
        let button = UIButton();
        let normalButtonImage = UIImage(named: "upButton")
        let selectedButtonImage = UIImage(named: "downButton")
        button.setImage(normalButtonImage, forState: .Normal)
        button.setImage(selectedButtonImage, forState: .Selected)
        button.addTarget(self, action: "toggleButtonClicked", forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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

    lazy var upcomingBusTimesContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var activityIndicator: MaterialActivityIndicatorView = {
        let activityIndicator = MaterialActivityIndicatorView(style: .Default)
        return activityIndicator
    }()

    // MARK: - Initalizers

    init(type: HopperBusRoutes, viewModel: RealTimeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self

        reachability.whenReachable = { reachability in
            self.networkConnectionExists = true
        }

        reachability.whenUnreachable = { reachability in
            self.networkConnectionExists = false
        }

        reachability.startNotifier()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (!textField.isFirstResponder()) {
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: viewModel, selector: "getRealTimeServicesAtCurrentStop", userInfo: nil, repeats: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "RealTime"
        view.addSubview(mapView)
        view.addSubview(textFieldContainer)
        view.addSubview(upcomingBusTimesContainerView)

        layoutSubviews()
        locationManager.startUpdatingLocation()

        textField.becomeFirstResponder()
        textFieldToggleButton.selected = true
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

    func layoutSubviews() {

        let views = [
            "mapView": mapView,
            "textField": textField,
            "liveView": upcomingBusTimesContainerView,
            "textFieldContainer": textFieldContainer,
            "toggleButton": textFieldToggleButton
        ]

        textFieldContainer.addConstraint(NSLayoutConstraint(item: textField, attribute: .CenterX, relatedBy: .Equal, toItem: textFieldContainer, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        textFieldContainer.addConstraint(NSLayoutConstraint(item: textField, attribute: .CenterY, relatedBy: .Equal, toItem: textFieldContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        textFieldContainer.addConstraint(NSLayoutConstraint(item: textFieldToggleButton, attribute: .CenterY, relatedBy: .Equal, toItem: textFieldContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        textFieldContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[textField(<=240)]", options: [], metrics: nil, views: views))
        textFieldContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[toggleButton(32)]-10-|", options: [], metrics: nil, views: views))
        textFieldContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[toggleButton(32)]", options: [], metrics: nil, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[mapView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[textFieldContainer]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[liveView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mapView][textFieldContainer][liveView]", options: [], metrics: nil, views: views))

        let height = self.view.frame.size.height

        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.5 * height))
        view.addConstraint(NSLayoutConstraint(item: textFieldContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.1 * height))
        view.addConstraint(NSLayoutConstraint(item: upcomingBusTimesContainerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.35 * height))
    }

    // MARK: - Actions

    func toggleButtonClicked() {

        if (textField.isFirstResponder()) {

            textField.text = viewModel.currentStopName()
            textField.resignFirstResponder()
            textFieldToggleButton.selected = false

            // Network Request

            requestRealtimeServices()

            if timer == nil {
                timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "requestRealtimeServices", userInfo: nil, repeats: true)
            }

        } else {

            if let t = timer {
                t.invalidate()
                timer = nil
            }

            textField.becomeFirstResponder()
            textFieldToggleButton.selected = true
        }
    }

    func requestRealtimeServices() {
        viewModel.getRealTimeServicesAtCurrentStop()

        for view in upcomingBusTimesContainerView.subviews {
            view.removeFromSuperview()
        }

        activityIndicator.center = upcomingBusTimesContainerView.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        showCurrentStopOnMap()
    }

    func showCurrentStopOnMap() {

        if let pin = currentStopAnnotation {
            mapView.removeAnnotation(pin)
        }

        let stopCoord = viewModel.locationCoordinatesForCurrentStop()
        let stopPin = MBXPointAnnotation()
        stopPin.coordinate = stopCoord
        stopPin.title = viewModel.currentStopName()
        stopPin.image = UIImage(named: "busImage")
        currentStopAnnotation = stopPin
        mapView.addAnnotation(currentStopAnnotation!)

        // Needed to get the right zoom level
        let userPin = MKPointAnnotation()
        userPin.coordinate = mapView.userLocation.coordinate

        mapView.showAnnotations([stopPin, userPin], animated: true)
        mapView.removeAnnotation(userPin)

    }
}

// MARK: - UIPickerView Delegate & Datasource

extension RealTimeViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    var pickerViewComponentLabelHeight: CGFloat {
        return UIFont.systemFontOfSize(UIFont.systemFontSize()).lineHeight * 2 * UIScreen.mainScreen().scale
    }
    
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

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let label : UILabel
        if view == nil {
            label = createPickerViewLabel()
        } else {
            label = view as! UILabel
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

        textField.text = viewModel.currentStopName()
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerViewComponentLabelHeight
    }
    
    func createPickerViewLabel() -> UILabel {
        let label = UILabel(frame: CGRectMake(0, 0, 0, pickerViewComponentLabelHeight))
        label.textAlignment = .Center
        label.numberOfLines = 2
        label.lineBreakMode = .ByTruncatingTail
        label.autoresizingMask = .FlexibleWidth
        label.textColor = .whiteColor()
        label.font = UIFont(name: "Avenir-Book", size: 17.0)
        return label
    }
}

// Mark: - RealTimeViewModel Delegate

extension RealTimeViewController: RealTimeViewModelDelegate {

    func viewModel(viewModel: RealTimeViewModel, didGetRealTimeServices realTimeServices: [RealTimeService], withSuccess: Bool) {
        activityIndicator.stopAnimating()

        var errorText = "No upcoming departures at this stop."
        if !networkConnectionExists { errorText = "No Internet Connection Available." }

        if realTimeServices.count == 0 {
            let label = UILabel()
            label.text = errorText
            label.numberOfLines = 2
            label.font = UIFont(name: "Avenir-Book", size: 22.0)
            label.textAlignment = .Center
            label.textColor = UIColor.lightGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            delay(0.5) {
                let views = ["view": label]
                self.upcomingBusTimesContainerView.addSubview(label)
                self.upcomingBusTimesContainerView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.upcomingBusTimesContainerView, attribute: .CenterY, multiplier: 1.0, constant: -10.0))
                self.upcomingBusTimesContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[view]-20-|", options: [], metrics: nil, views: views))
                self.activityIndicator.removeFromSuperview()
            }
            return
        }

        let upcomingBusTimesView = UpcomingBusTimesView(services: realTimeServices)
        upcomingBusTimesView.translatesAutoresizingMaskIntoConstraints = false
        delay(0.5) {
            self.upcomingBusTimesContainerView.addSubview(upcomingBusTimesView)
            let views = ["view": upcomingBusTimesView]
            self.upcomingBusTimesContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[view]|", options: [], metrics: nil, views: views))
            self.upcomingBusTimesContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: views))
            self.activityIndicator.removeFromSuperview()
        }
    }
}

// MARK: - UITextField Delegate

extension RealTimeViewController: UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textFieldToggleButton.selected = true
    }
}

// MARK: - MKMapView Delegate

extension RealTimeViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(overlay: overlay)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        let mbxAnnotation = annotation as? MBXPointAnnotation
        if mbxAnnotation != nil {
            let MBXSimpleStyleReuseIdentifier = "MBXSimpleStyleReuseIdentifier"
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier(MBXSimpleStyleReuseIdentifier)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: MBXSimpleStyleReuseIdentifier)
            }
            view?.image = mbxAnnotation!.image
            view?.canShowCallout = true
            return view
        }

        return nil
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {

        if !didCenterOnuserLocation {
            let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: false)
            didCenterOnuserLocation = !didCenterOnuserLocation
        }
    }
}