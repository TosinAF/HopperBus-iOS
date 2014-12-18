//
//  Constants.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

private let Device = UIDevice.currentDevice()
private let iosVersion = NSString(string: Device.systemVersion).doubleValue

let iOS8 = iosVersion >= 8
let iOS7 = iosVersion >= 7 && iosVersion < 8

let iPhone6And6Plus = UIScreen.mainScreen().bounds.width > 320
let iPhone6P = UIScreen.mainScreen().bounds.height == 736.0
let iPhone6 = UIScreen.mainScreen().bounds.height == 667.0
let iPhone5 = UIScreen.mainScreen().bounds.height == 568.0
let iPhone4S = UIScreen.mainScreen().bounds.height == 480.0

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
