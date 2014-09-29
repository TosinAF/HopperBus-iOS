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
    var currentSchedule : [Schedule] {

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
    var holidays: [String]?

    var currentTimes : [String] {
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

    init(stopID: String, name: String, termTime: [String]) {
        self.stopID = stopID
        self.stopName = name
        self.termTime = termTime
    }
}

private extension NSDate {

    class func isSaturday() -> Bool {
        if NSDate.getDay() == 7 { return true }
        return false
    }

    class func isSunday() -> Bool {
        if NSDate.getDay() == 1 { return true }
        return false
    }

    class func isWeekend() -> Bool {
        let weekday = NSDate.getDay()
        if weekday == 1 || weekday == 7 {
            return true
        }
        return false
    }

    class func isHoliday() -> Bool {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        let termDates = [
            "autumnTermBeginDate": dateFormatter.dateFromString("22-09-2014")!,
            "autumnTermEndDate": dateFormatter.dateFromString("12-12-2014")!,
            "springTermBeginDate": dateFormatter.dateFromString("12-01-2015")!,
            "springTermEndDate": dateFormatter.dateFromString("27-03-2015")!,
            "summerTermBeginDate":  dateFormatter.dateFromString("27-04-2015")!,
            "summerTermEndDate": dateFormatter.dateFromString("19-06-2015")!
        ]

        let today = NSDate()

        let isAutumnTerm = NSDate.isDate(today, inRangeFirstDate: termDates["autumnTermBeginDate"]!, lastDate: termDates["autumnTermEndDate"]!)
        let isSpringTerm = NSDate.isDate(today, inRangeFirstDate: termDates["springTermBeginDate"]!, lastDate: termDates["springTermEndDate"]!)
        let isSummerTerm = NSDate.isDate(today, inRangeFirstDate: termDates["summerTermBeginDate"]!, lastDate: termDates["summerTermEndDate"]!)

        if isAutumnTerm || isSpringTerm || isSummerTerm {
            return false
        }

        return true
    }

    class func isOutOfService() -> Bool {

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        let outOfServiceDay1 = dateFormatter.dateFromString("04-05-2015")!
        let outOfServiceDay2 = dateFormatter.dateFromString("25-05-2015")!

        let today = NSDate()

        if NSDate.isSameDay(today, asSecondDate: outOfServiceDay1) || NSDate.isSameDay(today, asSecondDate: outOfServiceDay2) {
            return true
        }

        let outOfServiceDates = [
            "range1Start": dateFormatter.dateFromString("25-12-2014")!,
            "range1End": dateFormatter.dateFromString("04-01-2015")!,
            "range2Start": dateFormatter.dateFromString("03-04-2015")!,
            "range2End": dateFormatter.dateFromString("07-04-2015")!,
            "range3Start":  dateFormatter.dateFromString("29-08-2015")!,
            "range3End": dateFormatter.dateFromString("31-08-2015")!
        ]

        let isInRange1 = NSDate.isDate(today, inRangeFirstDate: outOfServiceDates["range1Start"]!, lastDate: outOfServiceDates["range1End"]!)
        let isInRange2 = NSDate.isDate(today, inRangeFirstDate: outOfServiceDates["range2Start"]!, lastDate: outOfServiceDates["range2End"]!)
        let isInRange3 = NSDate.isDate(today, inRangeFirstDate: outOfServiceDates["range3Start"]!, lastDate: outOfServiceDates["range3End"]!)

        if isInRange1 || isInRange2 || isInRange3 {
            return true
        }

        return false
    }

    class func isDate(date: NSDate, inRangeFirstDate firstDate:NSDate, lastDate:NSDate) -> Bool {
        return !(date.compare(firstDate) == NSComparisonResult.OrderedAscending) && !(date.compare(lastDate) == NSComparisonResult.OrderedDescending)
    }

    class func getDay() -> Int {
        let date = NSDate()
        return NSCalendar.currentCalendar().component(.WeekdayCalendarUnit, fromDate: date)
    }

    class func isSameDay(firstDate: NSDate, asSecondDate secondDate: NSDate) -> Bool {
        let componentFlags = ( NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay )
        let components1 = NSCalendar.currentCalendar().components(componentFlags, fromDate:firstDate)
        let components2 = NSCalendar.currentCalendar().components(componentFlags, fromDate:secondDate)
        return  ( (components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day) )
    }
}
