//
//  RouteTimesViewModel.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/11/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

class RouteTimesViewModel: ViewModel {

    // MARK: - Properties

    let routeType: HopperBusRoutes
    let weekdayStops: [String]
    let weekendStops: [String]
    let stopTimings: [String: Times]

    var currentStops: [String] {
        if NSDate.isWeekend() { return weekendStops }
        return weekdayStops
    }

    init(data: [String: JSON], type: HopperBusRoutes) {
        routeType = type
        weekdayStops = RouteViewModel.castToStringArray(data["weekday_stops"]!.arrayValue)
        weekendStops = RouteViewModel.castToStringArray(data["weekend_stops"]!.arrayValue)
        stopTimings  = RouteViewModel.getStopTimings(data)
    }

    // MARK: Public Methods

    func numberOfStops() -> Int {
        return currentStops.count
    }

    func nameForStop(atIndex index: Int) -> String {
        let stopID = currentStops[index]
        let stopName = stopTimings[stopID]!.stopName
        return stopName
    }

    func nextThreeStopTimes(atIndex index: Int) -> [String] {
        let stopID = currentStops[index]

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"

        let currentTime = dateFormatter.dateFromString(NSDate.currentTimeAsString())
        let times = stopTimings[stopID]!.currentTimes

        // if less than 3 times, return what's available
        if times.count < 3 {
            var resultTimes = [String]()
            for time in times {
                let formattedTime = formatTimeStringForDisplay(time)
                resultTimes.append(formattedTime)
            }
            return resultTimes
        }

        for var i = 0; i < times.count; i++ {

            var possibleRouteTimeStart = dateFormatter.dateFromString(times[i])!

            // Check if time is past midnight & add an extra day
            let possibleTime = times[i]
            let rangeOfHour = Range(start: possibleTime.startIndex, end: advance(possibleTime.startIndex, 2))
            let hourStr = possibleTime.substringWithRange(rangeOfHour)
            if hourStr == "00" {
                let oneDay: Double = 60 * 60 * 24
                possibleRouteTimeStart = possibleRouteTimeStart.dateByAddingTimeInterval(oneDay)
            }

            let result = currentTime!.compare(possibleRouteTimeStart)

            switch (result) {
            case .OrderedAscending, .OrderedSame:

                // Return Last 3 Results if index is after the last 3
                var startIndex = i >= times.count - 3 ? times.count - 3 : i
                var stopIndex = startIndex + 3

                var resultTimes = [String]()
                for startIndex; startIndex < stopIndex; startIndex++ {
                    let time = formatTimeStringForDisplay(times[startIndex])
                    resultTimes.append(time)
                }

                return resultTimes
            case .OrderedDescending:
                continue
            }
        }

        // If no more buses for same day, show next day.
        var resultTimes = [String]()
        for var i = 0; i < 3; i++ {
            let time = formatTimeStringForDisplay(times[i])
            resultTimes.append(time)
        }

        return resultTimes
    }
}
