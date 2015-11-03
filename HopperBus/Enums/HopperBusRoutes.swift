//
//  HopperBusRoutes.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 9/14/15.
//  Copyright © 2015 Tosin Afolabi. All rights reserved.
//

// MARK: - HopperBusRoutes Enum

enum HopperBusRoutes: Int {
    case HB901 = 0, HB902, HBRealTime, HB903, HB904
    
    var title: String {
        let routeTitles = [
            "901 - Sutton Bonington",
            "902 - King's Meadow",
            "REAL TIME",
            "903 - Jubilee Campus",
            "904 - Royal Derby Hospital"
        ]
        return routeTitles[rawValue]
    }
    
    var routeCode: String {
        let routeCodes = [
            "901",
            "902",
            "RT",
            "903",
            "904"
        ]
        return routeCodes[rawValue]
    }
    
    static let allCases: [HopperBusRoutes] = [.HB901, .HB902, .HBRealTime, .HB903, .HB904]
}

extension HopperBusRoutes {
    
    static func routeCodeToEnum(code: String) -> HopperBusRoutes {
        let dict = [
            "901": HopperBusRoutes.HB901,
            "902": HopperBusRoutes.HB902,
            "903": HopperBusRoutes.HB903,
            "904": HopperBusRoutes.HB904,
            "RT" : HopperBusRoutes.HBRealTime
        ]
        
        return dict[code]!
    }
}
