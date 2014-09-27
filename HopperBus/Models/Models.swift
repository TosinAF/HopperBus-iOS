//
//  Models.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 26/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

struct Route {
    let termTime:  [Schedule]
    var saturdays: [Schedule]?
    var holidays:  [Schedule]?

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
    var holidays: [String]?

    init(stopID: String, name: String, termTime: [String]) {
        self.stopID = stopID
        self.stopName = name
        self.termTime = termTime
    }

    var description: String {
        return stopName + " " + termTime[0]
    }
}
