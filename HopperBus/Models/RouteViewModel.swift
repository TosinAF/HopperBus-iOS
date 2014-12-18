//
//  RouteViewModel.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 24/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//


// MARK: - ViewModel Class

class ViewModel {

    func updateScheduleIndex() {

    }

    func formatTimeStringForDisplay(timeStr: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        let timeAsDate = dateFormatter.dateFromString(timeStr)
        dateFormatter.dateFormat = "H:mm a"

        return dateFormatter.stringFromDate(timeAsDate!)
    }

    class func castToStringArray(jsonArr: [JSON]) -> [String] {
        var strArray = [String]()
        for element in jsonArr {
            strArray.append(element.stringValue)
        }
        return strArray
    }

    class func getStopTimings(data: [String: JSON]) -> [String: Times] {

        var stopTimings = [String: Times]()
        let stopTimingsJSON = data["stop_times"]!.arrayValue

        for stop in stopTimingsJSON {

            let stopID = stop["id"].stringValue
            let stopName = stop["name"].stringValue
            let termTimeStopTimes = stop["term_time"].arrayValue
            let termTime = RouteViewModel.castToStringArray(termTimeStopTimes)

            var timings = Times(stopID: stopID, name: stopName, termTime: termTime)

            if let saturdayTimes = stop["saturdays"].array {
                timings.saturdays = RouteViewModel.castToStringArray(saturdayTimes)
            }

            if let weekendTimes = stop["weekends"].array {
                timings.weekends = RouteViewModel.castToStringArray(weekendTimes)
            }

            if let holidayTimes = stop["holidays"].array {
                timings.holidays = RouteViewModel.castToStringArray(holidayTimes)
            }

            stopTimings[stopID] = timings
        }
        
        return stopTimings
    }
}

// MARK: - RouteViewModel Class

class RouteViewModel: ViewModel {

    // MARK: - Properties

    let route: Route
    let routeType: HopperBusRoutes
    let stopTimings: [String: Times]

    var stopIndex: Int = 0 {
        didSet { updateScheduleIndex() }
    }
    var scheduleIndex: Int = 0

    // MARK: - Public Methods

    init(data: [String: JSON], type: HopperBusRoutes) {
        self.route = RouteViewModel.getRoute(data)
        self.routeType = type
        self.stopTimings = RouteViewModel.getStopTimings(data)
        self.scheduleIndex = RouteViewModel.getScheduleIndexForCurrentTime(inRoute: route, atStop: stopIndex)
    }

    override func updateScheduleIndex() {
         self.scheduleIndex = RouteViewModel.getScheduleIndexForCurrentTime(inRoute: route, atStop: stopIndex)
    }

    func numberOfStopsForCurrentRoute() -> Int {
        return route.schedules[scheduleIndex].stops.count
    }

    func nameForStop(index: Int) -> String {
        let stop = route.schedules[scheduleIndex].stops[index]
        return stop.name
    }

    func idForStop(index: Int) -> String {
        let stop = route.schedules[scheduleIndex].stops[index]
        return stop.id
    }

    func timeForStop(index: Int) -> String {
        let stop = route.schedules[scheduleIndex].stops[index]
        let formattedTime = formatTimeStringForDisplay(stop.time)
        return formattedTime
    }

    func timeTillStop(index: Int) -> String {
        let stop = route.schedules[scheduleIndex].stops[index]

        let currentTimeStr = NSDate.currentTimeAsString()
        let stopTimeStr = stop.time

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"

        let currentTime = dateFormatter.dateFromString(currentTimeStr)!
        let stopTime = dateFormatter.dateFromString(stopTimeStr)!

        let diff = stopTime.timeIntervalSinceDate(currentTime)

        switch abs(diff) {
            case 0...60:
                return "1m"
            case 61..<3600:
                let minutes = Int(floor(abs(diff) / 60))
                return "\(minutes)m"
            default:
                let formattedTime = formatTimeStringForDisplay(stop.time)
                return formattedTime
        }
    }

    func stopTimingsForStop(id: String) -> Times {
        return stopTimings[id]!
    }

    func isRouteInService() -> Bool {

        if NSDate.isOutOfService() {
            return false
        }

        if routeType == .HB902 || routeType == .HB904 {
            if NSDate.isWeekend() {
                return false
            }
        }

        if routeType == .HB903 {
            if (NSDate.isWeekend() && NSDate.isHoliday()) ||  NSDate.isSunday() {
                return false
            }
        }

        return true
    }
}

// MARK: - Private Methods

private extension RouteViewModel {

    class func getRoute(data: [String: JSON]) -> Route {

        let termTime = data["term_time_schedule"]!.arrayValue
        let termTimeSchedules = RouteViewModel.getSchedules(termTime)

        var route = Route(termTime: termTimeSchedules)

        if let saturdays = data["saturday_schedule"] {
            route.saturdays = RouteViewModel.getSchedules(saturdays.arrayValue)
        }

        if let holidays = data["holiday_schedule"] {
            route.holidays = RouteViewModel.getSchedules(holidays.arrayValue)
        }

        return route
    }

    class func getSchedules(route: [JSON]) -> [Schedule] {

        var schedules = [Schedule]()

        for schedule in route {
            var stops = [Stop]()
            for stop in schedule.arrayValue {

                let id = stop[0].stringValue
                let name = stop[1].stringValue
                let time = stop[2].stringValue
                let s = Stop(id: id, name: name, time: time)
                stops.append(s)
            }
            schedules.append(Schedule(stops: stops))
        }

        return schedules
    }

    class func getScheduleIndexForCurrentTime(inRoute route: Route, atStop stopIndex: Int) -> Int {

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"

        let currentTime = dateFormatter.dateFromString(NSDate.currentTimeAsString())

        for (index, schedule) in enumerate(route.schedules) {

            let time = schedule.stops[stopIndex].time

            let possibleRouteTimeStart = dateFormatter.dateFromString(schedule.stops[stopIndex].time)
            let result = currentTime!.compare(possibleRouteTimeStart!)

            switch (result) {
                case .OrderedAscending, .OrderedSame:
                    if index == 0 { return 1 }
                    return index
                case .OrderedDescending:
                    continue
            }
        }

        return 0
    }
}
