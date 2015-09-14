//
//  TableView.Swift
//  HopperBus
//
//  Created by Tosin Afolabi on 02/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

@objc protocol TableViewDoubleTapDelegate {
    func tableView(tableView: TableView, didDoubleTapRowAtIndexPath indexPath: NSIndexPath)
}

class TableView: UITableView {

    weak var doubleTapDelegate: TableViewDoubleTapDelegate?
    private var isDoubleTap = false

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for t in touches {
            let touch = t as UITouch
            let touchPoint = touch.locationInView(self)
            let indexPath = self.indexPathForRowAtPoint(touchPoint)

            if (touch.tapCount == 1) {
                if let ip = indexPath {
                    isDoubleTap = false
                    delay(0.25) {
                        if !self.isDoubleTap {
                            self.delegate?.tableView?(self, didSelectRowAtIndexPath: ip)
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
