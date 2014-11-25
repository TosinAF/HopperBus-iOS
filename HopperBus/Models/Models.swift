//
//  Models.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import Foundation

struct Route {
    let termTime:  [Schedule]
    var saturdays: [Schedule]?
    var holidays:  [Schedule]?
    var schedules: [Schedule] {

        if saturdays == nil || holidays == nil {
            return termTime
        }

        if let sat = saturdays {
            if NSDate.isSaturday() { return sat }
        }

        if let hol = holidays {
            if NSDate.isHoliday() { return hol }
        }

        return termTime
    }

    init(termTime: [Schedule]) {
        self.termTime = termTime
    }
}

struct Schedule {
    let stops: [Stop]
}

struct Stop {
    let id: String
    let name: String
    let time: String
}

struct Times {
    let stopID: String
    let stopName: String
    var termTime: [String]
    var saturdays: [String]?
    var weekends: [String]?
    var holidays: [String]?

    var currentTimes : [String] {
        if saturdays == nil || holidays == nil {
            return termTime
        }

        if let hol = holidays {
            if NSDate.isHoliday() { return hol }
        }

        if let wkd = weekends {
            if NSDate.isWeekend() { return wkd }
        }

        if let sat = saturdays {
            if NSDate.isSaturday() { return sat }
        }

        return termTime
    }

    init(stopID: String, name: String, termTime: [String]) {
        self.stopID = stopID
        self.stopName = name
        self.termTime = termTime
    }
}

struct APIRoute {
    let stops: [APIStop]
}

struct APIStop {
    let name: String
    let code: String
    let coord: CLLocationCoordinate2D
}


