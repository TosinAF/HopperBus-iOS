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
