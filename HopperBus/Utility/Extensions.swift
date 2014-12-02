//
//  Extensions.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

extension UIColor {

    class func HopperBusBrandColor() -> UIColor {
        return UIColor(red: 0.000, green: 0.294, blue: 0.416, alpha: 1.0)
    }
}

extension UIImage {

    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)

        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect);

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return image
    }
}

extension Array {
    func flattenToString() -> String {
        var finalString = ""
        for (index, str) in enumerate(self) {
            let s = str as String
            let ss = s.stringByReplacingOccurrencesOfString(":", withString: ".", options: .LiteralSearch, range: nil)
            finalString += "\(ss) "
        }
        return finalString
    }
}

extension String {
    func doubleValue() -> Double
    {
        let minusAscii: UInt8 = 45
        let dotAscii: UInt8 = 46
        let zeroAscii: UInt8 = 48

        var res = 0.0
        let ascii = self.utf8

        var whole = [Double]()
        var current = ascii.startIndex

        let negative = current != ascii.endIndex && ascii[current] == minusAscii
        if (negative)
        {
            current = current.successor()
        }

        while current != ascii.endIndex && ascii[current] != dotAscii
        {
            whole.append(Double(ascii[current] - zeroAscii))
            current = current.successor()
        }

        //whole number
        var factor: Double = 1
        for var i = countElements(whole) - 1; i >= 0; i--
        {
            res += Double(whole[i]) * factor
            factor *= 10
        }

        //mantissa
        if current != ascii.endIndex
        {
            factor = 0.1
            current = current.successor()
            while current != ascii.endIndex
            {
                res += Double(ascii[current] - zeroAscii) * factor
                factor *= 0.1
                current = current.successor()
            }
        }

        if (negative)
        {
            res *= -1;
        }
        
        return res
    }

    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

extension NSDate {

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
        if iOS8 {
            return NSCalendar.currentCalendar().component(.WeekdayCalendarUnit, fromDate: date)
        } else {
            let nsDateComponents = NSCalendar.currentCalendar().components(.WeekdayCalendarUnit, fromDate: date)
            return nsDateComponents.weekday
        }
    }

    class func isSameDay(firstDate: NSDate, asSecondDate secondDate: NSDate) -> Bool {
        let componentFlags = ( NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay )
        let components1 = NSCalendar.currentCalendar().components(componentFlags, fromDate:firstDate)
        let components2 = NSCalendar.currentCalendar().components(componentFlags, fromDate:secondDate)
        return  ( (components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day) )
    }
}
