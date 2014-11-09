//
//  RealTimeViewModel.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 08/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

extension HopperBusRoutes {

    static func routeCodeToEnum(code: String) -> HopperBusRoutes {
        let dict = [
            "901": HopperBusRoutes.HB901,
            "902": HopperBusRoutes.HB902,
            "903": HopperBusRoutes.HB903,
            "904": HopperBusRoutes.HB904
        ]

        return dict[code]!
    }
}

class RealTimeViewModel {

    // https://api.nctx.co.uk/api/v1/departures/3390RA63/realtime - api routes

    var selectedRouteType = HopperBusRoutes.HB901
    var selectedStopIndex = 0
    let routes = [HopperBusRoutes: APIRoute]()
    let routeCodes = [String]()

    init() {

        let filePath = NSBundle.mainBundle().pathForResource("APICodes", ofType: "json")!
        let data = NSData(contentsOfFile: filePath, options: nil, error: nil)!
        let json = JSON(data: data)

        var routeCodes = [String]()
        for code in json["routeCodes"].arrayValue {
            routeCodes.append(code.stringValue)
        }
        self.routeCodes = routeCodes

        var routes = [HopperBusRoutes: APIRoute]()
        for (key: String, subJson: JSON) in json {
            if key == "routeCodes" { continue }

            var stops = [APIStop]()
            let stopsData = subJson.dictionaryValue
            for (key: String, subJson: JSON) in stopsData {
                let name = key
                let attr = subJson.arrayValue
                let code = attr[0].stringValue
                let lat = attr[1].stringValue
                let long = attr[2].stringValue
                let coord = CLLocationCoordinate2D(latitude: lat.doubleValue(), longitude: long.doubleValue())
                let apiStop = APIStop(name: name, code: code, coord: coord)
                stops.append(apiStop)
            }

            let routeType = HopperBusRoutes.routeCodeToEnum(key)
            let apiRoute = APIRoute(stops: stops)
            routes[routeType] = apiRoute
        }
        self.routes = routes // Immutable models ftw!!!
    }

    func getRoute(atIndex index: Int) -> String {
        return routeCodes[index]
    }

    func getNumberOfRoutes() -> Int {
        return routeCodes.count
    }

    func getStopForCurrentRoute(atIndex index: Int) -> String {
        let stops = routes[selectedRouteType]!.stops
        return stops[index].name
    }

    func getNumberOfStopsForCurrentRoute() -> Int {
        return routes[selectedRouteType]!.stops.count
    }

    func updateSelectedRoute(#index: Int) {
        let routeCode = getRoute(atIndex: index)
        let routeType = HopperBusRoutes.routeCodeToEnum(routeCode)
        selectedRouteType = routeType
    }

    func textForSelectedRouteAndStop() -> String {
        let routeCode = selectedRouteType.routeCode
        let stopName = getStopForCurrentRoute(atIndex: selectedStopIndex)
        return "\(routeCode) - \(stopName)"
    }
}
