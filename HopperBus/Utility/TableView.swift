//
//  TableView.Swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

@objc protocol TableViewDoubleTapDelegate {
    func tableView(tableView: TableView, didDoubleTapRowAtIndexPath indexPath: NSIndexPath)
}

class TableView: UITableView {

    weak var doubleTapDelegate: TableViewDoubleTapDelegate?
    private var isDoubleTap = false

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for t in touches {
            
            let touch = t as UITouch
            let touchPoint = touch.locationInView(self)
            let indexPath = self.indexPathForRowAtPoint(touchPoint)

            if (touch.tapCount == 1) {
                if let ip = indexPath {
                    isDoubleTap = false
                    delay(0.25) {
                        if !self.isDoubleTap {
                            self.delegate?.tableView!(self, didSelectRowAtIndexPath: ip)
                            self.isDoubleTap = false
                        }
                    }
                }
            }

            if (touch.tapCount == 2) {
                if let ip = indexPath {
                    isDoubleTap = true
                    self.doubleTapDelegate?.tableView(self, didDoubleTapRowAtIndexPath: ip)
                }
            }
        }
    }
}
