//
//  RouteViewModel.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 24/09/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
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

    static let allCases: [HopperBusRoutes] = [.HB902, .HB902, .HBRealTime, .HB903, .HB904]
}

// MARK: - RouteViewModelContainer Class

class RouteViewModelContainer {

    let routeViewModels: [String: RouteViewModel]

    init() {

        let filePath = NSBundle.mainBundle().pathForResource("Routes", ofType: "json")!
        let data = NSData(contentsOfFile: filePath, options: nil, error: nil)!
        let json = JSON(data: data)

        let data902 = json["route902"].dictionaryValue!
        let data903 = json["route903"].dictionaryValue!
        let data904 = json["route904"].dictionaryValue!

        let route902 = RouteViewModel(data: data902, type: .HB902)
        let route903 = RouteViewModel(data: data903, type: .HB903)
        let route904 = RouteViewModel(data: data904, type: .HB904)

        routeViewModels = [
            HopperBusRoutes.HB902.routeCode: route902,
            HopperBusRoutes.HB903.routeCode: route903,
            HopperBusRoutes.HB904.routeCode: route904
        ]
    }

    func routeViewModel(type: HopperBusRoutes) -> RouteViewModel {
        return routeViewModels[type.routeCode]!
    }

    func updateScheduleIndexForRoutes() {
        for (key,routeVM) in routeViewModels {
            routeVM.updateScheduleIndex()
        }
    }
}

// MARK: - RouteViewModel Class

class RouteViewModel {

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

    func updateScheduleIndex() {
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
}

// MARK: - Private Methods

private extension RouteViewModel {

    class func getRoute(data: [String: JSON]) -> Route {

        let termTime = data["term_time_schedule"]!.arrayValue
        let termTimeSchedules = RouteViewModel.getSchedules(termTime!)

        var route = Route(termTime: termTimeSchedules)

        if let saturdays = data["saturday_schedule"] {
            route.saturdays = RouteViewModel.getSchedules(saturdays.arrayValue!)
        }

        if let holidays = data["holiday_schdule"] {
            route.holidays = RouteViewModel.getSchedules(holidays.arrayValue!)
        }

        return route
    }

    class func getSchedules(route: [JSON]) -> [Schedule] {

        var schedules = [Schedule]()

        for schedule in route {
            var stops = [Stop]()
            for stop in schedule.arrayValue! {

                let id = stop[0].stringValue!
                let name = stop[1].stringValue!
                let time = stop[2].stringValue!
                let s = Stop(id: id, name: name, time: time)
                stops.append(s)
            }
            schedules.append(Schedule(stops: stops))
        }

        return schedules
    }

    class func getStopTimings(data: [String: JSON]) -> [String: Times] {

        var stopTimings = [String: Times]()
        let stopTimingsJSON = data["stop_times"]!.arrayValue

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

    class func castToStringArray(jsonArr: [JSON]) -> [String] {
        var strArray = [String]()
        for element in jsonArr {
            strArray.append(element.stringValue!)
        }
        return strArray
    }

    func formatTimeStringForDisplay(timeStr: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")

        let timeAsDate = dateFormatter.dateFromString(timeStr)
        dateFormatter.dateFormat = "H:mm a"

        return dateFormatter.stringFromDate(timeAsDate!)
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
