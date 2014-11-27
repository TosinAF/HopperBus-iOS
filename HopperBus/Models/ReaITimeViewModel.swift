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

protocol RealTimeViewModelDelegate: class {
    func viewModel(viewModel: RealTimeViewModel, didGetRealTimeServices realTimeServices: [RealTimeService], withSuccess: Bool)
}


class RealTimeViewModel: ViewModel {

    let routes = [HopperBusRoutes: APIRoute]()
    let routeCodes = [String]()

    var selectedRouteType = HopperBusRoutes.HB901
    var selectedStopIndex = 0
    weak var delegate: RealTimeViewModelDelegate?


    init(data: [String: JSON], type: HopperBusRoutes) {
        let json = data

        var routeCodes = [String]()
        for code in data["routeCodes"]!.arrayValue {
            routeCodes.append(code.stringValue)
        }
        self.routeCodes = routeCodes

        var routes = [HopperBusRoutes: APIRoute]()
        for (key: String, subJson: JSON) in data {
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

    func currentStopName() -> String {
        let stopName = getStopForCurrentRoute(atIndex: selectedStopIndex)
        return stopName
    }

    func locationCoordinatesForCurrentStop() -> CLLocationCoordinate2D {
        let apiRoute = routes[selectedRouteType]!
        return apiRoute.stops[selectedStopIndex].coord
    }

    func getRealTimeServicesAtCurrentStop() {
        let apiRoute = routes[selectedRouteType]!
        let apiStopCode = apiRoute.stops[selectedStopIndex].code
        let url = "https://api.nctx.co.uk/api/v1/departures/\(apiStopCode)/realtime"

        Manager.sharedInstance.request(.GET, url)
            .responseSwiftyJSON { (request, response, json, error) in

                var realTimeServices = [RealTimeService]()
                for service in json.arrayValue {
                    let busService = service["busService"].stringValue
                    if busService[0] != "9" {
                        continue
                    }

                    let timeTill = service["minutes"].stringValue
                    let arr = split(timeTill, { $0 == "."}, maxSplit: Int.max, allowEmptySlices: false)
                    let minutesTill = arr.first!

                    let realTimeService = RealTimeService(busService: busService, minutesTill: minutesTill)
                    realTimeServices.append(realTimeService)
                }

                realTimeServices.sort({ $0.minutesTill.toInt()! < $1.minutesTill.toInt()! })

                if realTimeServices.count > 3 {
                    realTimeServices = [realTimeServices[0], realTimeServices[1], realTimeServices[2]]
                }

                self.delegate?.viewModel(self, didGetRealTimeServices: realTimeServices, withSuccess: true)
        }

    }
}
