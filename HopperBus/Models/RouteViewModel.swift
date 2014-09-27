//
//  RouteViewModel.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 24/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

// MARK: - HopperBus Routes Enum

enum HopperBusRoutes: Int {
    case HB901 = 0, HB902, HB903, HB904

    var title: String {
        let routeTitles = [
            "901 - Sutton Bonington",
            "902 - King's Meadow",
            "903 - Jubilee Campus",
            "904 - Royal Derby Hospital"
        ]

        return routeTitles[toRaw()]
    }

    var filePath: String {
        let fileTitles = [
            "Route901",
            "Route902",
            "Route903",
            "Route904"
        ]

        return NSBundle.mainBundle().pathForResource(fileTitles[toRaw()], ofType: "json")!
    }
}

// MARK: - RouteViewModel Class

class RouteViewModel: NSObject {

    let POSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")

    var currentRouteType: HopperBusRoutes
    var currentRoute: Route
    var stopTimings: [String: Times]
    var currentStopIndex: Int = 0
    var currentScheduleIndex: Int = 1

    init(type: HopperBusRoutes) {

        self.currentRouteType = type
        self.currentRoute = RouteViewModel.getRoute(currentRouteType)
        self.stopTimings = RouteViewModel.getStopTimings(currentRouteType)
        self.currentScheduleIndex = RouteViewModel.getStopTimesIndexForCurrentTime(currentRoute, startIndex: currentStopIndex)

        let x = RouteViewModel.getRoute(.HB904)

        for y in x.termTime {
            for z in y.stops {
                //println(z.name)
                //println(z.time)
            }
        }

        println(self.stopTimings["UPED-1"]!.description)
        super.init()
    }

    func numberOfStopsForCurrentRoute() -> Int {
        //return currentRoute.stops.count
        return 6
    }


    func nameForStop(index: Int) -> String {
        let stop = currentRoute.termTime[currentScheduleIndex].stops[index]
        return stop.name
    }

    func timesForStop(index: Int) -> (String, String) {

        let stop = currentRoute.termTime[currentScheduleIndex].stops[index]

        let timeStr1 = getPreviousTimeForStop(stop)
        let timeStr2 = stop.time

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        let time1 = dateFormatter.dateFromString(timeStr1)
        let time2 = dateFormatter.dateFromString(timeStr2)

        dateFormatter.dateFormat = "h:mm a"

        let formattedTime1 = dateFormatter.stringFromDate(time1!)
        let formattedTime2 = dateFormatter.stringFromDate(time2!)

        // check for 00:00

        return (formattedTime1, formattedTime2)
    }
}

// MARK: - Private Methods

private extension RouteViewModel {

    func getPreviousTimeForStop(stop: Stop) -> String {

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"

        for (index, time) in enumerate(self.stopTimings[stop.id]!.termTime) {

            let timeDate = dateFormatter.dateFromString(time)
            let timeStr = dateFormatter.stringFromDate(timeDate!)
            if timeStr == stop.time {
                return self.stopTimings[stop.id]!.termTime[index - 1]
            }
        }

        return "-"
    }

    class func getRoute(type: HopperBusRoutes) -> Route {

        let data = NSData.dataWithContentsOfFile(type.filePath, options: nil, error: nil)
        let json = JSON(data: data)

        let termTime = json["term_time_schedule"].arrayValue
        let termTimeSchedules = RouteViewModel.getSchedules(termTime!)

        var route = Route(termTime: termTimeSchedules)

        if let saturdays = json["saturday_schedule"].arrayValue {
            route.saturdays = RouteViewModel.getSchedules(saturdays)
        }

        if let holidays = json["holiday_schdule"].arrayValue {
            route.holidays = RouteViewModel.getSchedules(holidays)
        }

        return route
    }

    class func getSchedules(route: [JSON]) -> [Schedule] {

        var schedules = [Schedule]()

        for schedule in route {
            var stops = [Stop]()
            for stop in schedule.arrayValue! {
                let name = stop[0].stringValue!
                let time = stop[1].stringValue!
                let id = stop[2].stringValue!
                let s = Stop(id: id, name: name, time: time)
                stops.append(s)
            }
            schedules.append(Schedule(stops: stops))
        }

        return schedules
    }

    class func getStopTimings(type: HopperBusRoutes) -> [String: Times] {

        let data = NSData.dataWithContentsOfFile(type.filePath, options: nil, error: nil)
        let json = JSON(data: data)

        var stopTimingsJSON = json["stop_times"].arrayValue

        var stopTimings = [String: Times]()

        for stop in stopTimingsJSON! {

            let stopID = stop["id"].stringValue!
            let stopName = stop["name"].stringValue!
            let termTimeStopTimes = stop["term_time"].arrayValue
            let termTime = RouteViewModel.castToStringArray(termTimeStopTimes!)

            var timings = Times(stopID: stopID, name: stopName, termTime: termTime)

            if let saturdayTimes = stop["saturdays"].arrayValue {
                timings.saturdays = RouteViewModel.castToStringArray(saturdayTimes)
            }

            if let holidayTimes = stop["holidays"].arrayValue {
                timings.holidays = RouteViewModel.castToStringArray(holidayTimes)
            }

            stopTimings[stopID] = timings
        }

        return stopTimings
    }

    class func getStopTimesIndexForCurrentTime(route: Route, startIndex: Int) -> Int {

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"

        let currentTime = dateFormatter.dateFromString(NSDate.currentTimeAsString())
        //let currentTime = dateFormatter.dateFromString("17:00")

        for (index, schedule) in enumerate(route.termTime) {

            let possibleRouteTimeStart = dateFormatter.dateFromString(schedule.stops[startIndex].time)
            let result = currentTime!.compare(possibleRouteTimeStart!)

            switch (result) {
                case .OrderedAscending, .OrderedSame:
                    if index == 0 { return 1 }
                    return index
                case .OrderedDescending:
                    continue
            }
        }
        
        // Default Value: return the 1st & 2nd stop times
        return 1
    }

    class func castToStringArray(jsonArr: [JSON]) -> [String] {
        var strArray = [String]()
        for element in jsonArr {
            strArray.append(element.stringValue!)
        }
        return strArray
    }

}

private extension NSDate {

    class func currentTimeAsString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(NSDate())
    }
}
