//
//  Constants.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

let Device = UIDevice.currentDevice()

private let iosVersion = NSString(string: Device.systemVersion).doubleValue

let iOS8 = iosVersion >= 8
let iOS7 = iosVersion >= 7 && iosVersion < 8

let iPhone6And6Plus = UIScreen.mainScreen().bounds.width > 320
let iPhone5 = UIScreen.mainScreen().bounds.height == 569
let iPhone4S = UIScreen.mainScreen().bounds.height == 480
