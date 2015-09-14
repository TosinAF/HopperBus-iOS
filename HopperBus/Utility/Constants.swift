//
//  Constants.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

let kHasHomeViewBeenDisplayedYetKey = "hasHomwViewBeenDisplayedYet"

let iPhone6Or6Plus = UIScreen.mainScreen().bounds.width > 320
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
