//
//  HBAccordionScheme.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 05/10/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class AccordionScheme: NSObject {

    typealias U = UITableViewCell

    typealias ConfigurationHandler = (cell: U, index: Int) -> Void
    typealias SelectionHandler = (tableView: UITableView, cell: U, selectedIndex: Int) -> Void
    typealias DoubleTapHandler = (tableView: UITableView, cell: U, selectedIndex: Int) -> Void

    typealias AccordionConfigurationHandler = (cell: U, parentIndex: Int) -> Void
    typealias AccordionSelectionHandler = (cell: U, selectedIndex: Int) -> Void
    typealias AccordionDoubleTapHandler = (cell: U, index: Int) -> Void
    typealias AccordionHeightHandler = (parentIndex: Int) -> CGFloat

    typealias RowCountHandler = () -> Int

    var reuseIdentifier: String?
    var accordionReuseIdentifier: String?

    private var expanded = false

    var accordionIndex = 1
    var parentIndex: Int {
        return accordionIndex - 1
    }

    var rowCountHandler: RowCountHandler?

    var configurationHandler: ConfigurationHandler?
    var selectionHandler: SelectionHandler?
    var doubleTapHandler: DoubleTapHandler?

    var accordionConfigurationHandler: AccordionConfigurationHandler?
    var accordionSelectionHandler: AccordionSelectionHandler?
    var accordionDoubleTapHandler: AccordionDoubleTapHandler?
    var accordionHeightHandler: AccordionHeightHandler?

    var numberOfCells: Int {
        let count = rowCountHandler!()
        return expanded ? count + 1 : count
    }

    func configureCell(cell: UITableViewCell, withAbsoluteIndex index: Int)  {
        if isAccordion(index) {
            accordionConfigurationHandler!(cell: cell as U, parentIndex: parentIndex)
        } else {
            let cIndex = expanded ? getRelativeIndex(index) : index
            configurationHandler!(cell: cell as U, index: cIndex )
        }
    }

    func handleSelection(tableView: UITableView, cell: UITableViewCell, withAbsoluteIndex index: Int) {
        if isAccordion(index) {
            accordionSelectionHandler!(cell: cell as U, selectedIndex: index)
        } else {
            let cIndex = expanded ? getRelativeIndex(index) : index

            if expanded {
                // Hide expanded cell smoothly
                CATransaction.begin()
                CATransaction.setCompletionBlock { () -> Void in
                    self.selectionHandler!(tableView: tableView, cell: cell as U, selectedIndex: cIndex)
                }
                collapseExpandedCell(tableView)
                CATransaction.commit()
            } else {
                self.selectionHandler!(tableView: tableView, cell: cell as U, selectedIndex: cIndex)
            }
        }
    }

    func handleDoubleTap(tableView: UITableView, withAbsoluteIndex index: Int) {
        if isAccordion(index) {

            return

        } else {

            if !expanded {

                // Add a cell below the double tapped cell

                let newAccordionIndex = index + 1
                let indexPathToAdd = NSIndexPath(forRow: newAccordionIndex, inSection: 0)

                tableView.beginUpdates()
                expanded = true
                accordionIndex = newAccordionIndex
                tableView.insertRowsAtIndexPaths([indexPathToAdd], withRowAnimation: .Fade)
                tableView.endUpdates()

            } else {

                if index == parentIndex {
                    collapseExpandedCell(tableView)
                    return
                }

                // Remove the current accordion cell & add a new one
                // below the double tapped cell

                let indexPathToRemove = NSIndexPath(forRow: accordionIndex, inSection: 0)

                let newAccordionIndex = index > accordionIndex ? index : index + 1
                let indexPathToAdd = NSIndexPath(forRow: newAccordionIndex, inSection: 0)

                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPathToRemove], withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths([indexPathToAdd], withRowAnimation: .Automatic)
                accordionIndex = newAccordionIndex
                tableView.endUpdates()
            }
        }
    }

    func getReuseIdentifier(index: Int) -> String {
        return isAccordion(index) ? accordionReuseIdentifier! : reuseIdentifier!
    }

    func collapseExpandedCell(tableView: UITableView) {
        let indexPathToRemove = NSIndexPath(forRow: accordionIndex, inSection: 0)
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPathToRemove], withRowAnimation: .Middle)
        accordionIndex = 1
        expanded = false
        tableView.endUpdates()
    }
}

extension AccordionScheme {

    func getRelativeIndex(index: Int) -> Int {
        if index > accordionIndex { return index - 1 }
        return index
    }

    func isAccordion(index: Int) -> Bool {
        return expanded && index == accordionIndex
    }
}
