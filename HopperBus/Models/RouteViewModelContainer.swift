//
//  RouteViewModelContainer.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

// MARK: - RouteViewModelContainer Class

import UIKit
import SwiftyJSON

class RouteViewModelContainer {

    let routeViewModels: [String: ViewModel]
    
    lazy var routeViewControllers: [UIViewController] = {
        var vcs = [UIViewController]()
        for type in HopperBusRoutes.allCases {
            if type == .HB901 {
                let routeViewModel = self.routeViewModel(type) as! RouteTimesViewModel
                let rtvc = RouteTimesViewController(type: type, routeViewModel: routeViewModel)
                vcs.append(rtvc)
            } else if type == .HBRealTime {
                let viewModel = self.routeViewModel(type) as! RealTimeViewModel
                let rtvc = RealTimeViewController(type: type, viewModel: viewModel)
                vcs.append(rtvc)
            } else {
                let routeViewModel = self.routeViewModel(type) as! RouteViewModel
                let rvc = RouteViewController(type: type, routeViewModel: routeViewModel)
                vcs.append(rvc)
            }
        }
        return vcs
    }()

    init() {

        let p = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
        let path = p.stringByAppendingPathComponent("routeData")
        guard let data = NSData(contentsOfFile: path) else {
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
