//
//  RouteViewModelContainer.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

// MARK: - RouteViewModelContainer Class

import SwiftyJSON

class RouteViewModelContainer {

    let routeViewModels: [String: ViewModel]

    init() {

        let filePath = NSBundle.mainBundle().pathForResource("Routes", ofType: "json")!
        guard let data = NSData(contentsOfFile: filePath) else {
            fatalError("Routes File could not be read.")
        }
        
        let json = JSON(data: data)

        let data901 = json["route901"].dictionaryValue
        let data902 = json["route902"].dictionaryValue
        let data903 = json["route903"].dictionaryValue
        let data904 = json["route904"].dictionaryValue
        let dataRealTime = json["api_codes"].dictionaryValue

        let route901 = RouteTimesViewModel(data: data901, type: HopperBusRoutes.HB901)
        let route902 = RouteViewModel(data: data902, type: .HB902)
        let route903 = RouteViewModel(data: data903, type: .HB903)
        let route904 = RouteViewModel(data: data904, type: .HB904)
        let realTime = RealTimeViewModel(data: dataRealTime, type: .HBRealTime)

        routeViewModels = [
            HopperBusRoutes.HB901.routeCode: route901,
            HopperBusRoutes.HB902.routeCode: route902,
            HopperBusRoutes.HB903.routeCode: route903,
            HopperBusRoutes.HB904.routeCode: route904,
            HopperBusRoutes.HBRealTime.routeCode: realTime
        ]
    }

    func routeViewModel(type: HopperBusRoutes) -> ViewModel {
        return routeViewModels[type.routeCode]!
    }
    
    func updateScheduleIndexForRoutes() {
        for (_,routeVM) in routeViewModels {
            routeVM.updateScheduleIndex()
        }
    }
}

extension NSDate {
    class func currentTimeAsString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(NSDate())
    }
}
