//
//  HBTableScheme.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 05/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class TableDataSource: NSObject, UITableViewDataSource {

    var scheme: AccordionScheme

    init(scheme: AccordionScheme) {
        self.scheme = scheme
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheme.numberOfCells
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = scheme.getReuseIdentifier(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        scheme.configureCell(cell, withAbsoluteIndex: indexPath.row)
        return cell
    }
}
