//
//  RouteViewController.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {

    // MARK: - Properties

    let routeType: HopperBusRoutes!
    let routeViewModel: RouteViewModel!

    var animTranslationStart: CGPoint!
    var animTranslationFinish: CGPoint!

    var dataSource: TableDataSource!

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = self.routeType.title.uppercaseString
        return view
    }()

    lazy var tableView: TableView = {
        let tableView = TableView()
        tableView.delegate = self
        tableView.doubleTapDelegate = self
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 64.0, 0.0);
        tableView.registerClass(StopTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(StopTimesTableViewCell.self, forCellReuseIdentifier: "dropdown")
        return tableView
    }()

    lazy var animatedCircleView: UIView = {
        let circleView = UIView(frame: CGRectMake(0, 0, 14, 14))
        circleView.backgroundColor = UIColor.selectedGreen()
        circleView.layer.borderColor = UIColor.selectedGreen().CGColor
        circleView.layer.cornerRadius = 7
        return circleView
    }()

    // MARK: - Initalizers

    init(type: HopperBusRoutes, routeViewModel: RouteViewModel) {
        self.routeType = type
        self.routeViewModel = routeViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)

        tableView.frame = view.frame

        createTableScheme()

        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = self.routeType == HopperBusRoutes.HB904 ? 65 : 55
        tableView.dataSource = dataSource
    }

    override func viewDidLayoutSubviews() {
        println("i was celled woop")
        let top = self.topLayoutGuide.length;
        let bottom = self.bottomLayoutGuide.length;
        let newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
        tableView.contentInset = newInsets;
    }
}

// MARK: - TableScheme

extension RouteViewController {

    func createTableScheme() {

        let scheme = AccordionScheme()

        scheme.reuseIdentifier = "cell"
        scheme.accordionReuseIdentifier = "dropdown"

        scheme.rowCountHandler = { () in
            return self.routeViewModel.numberOfStopsForCurrentRoute()
        }

        scheme.accordionHeightHandler = { (parentIndex) in
            let cell = StopTimesTableViewCell(frame: CGRectZero)
            let rvm = self.routeViewModel
            let times = rvm.stopTimingsForStop(rvm.idForStop(parentIndex))
            cell.times = times
            return cell.height
        }

        scheme.configurationHandler = { (c, index) in
            let cell = c as StopTableViewCell
            let rvm = self.routeViewModel

            cell.titleLabel.text = rvm.nameForStop(index)
            cell.timeLabel.text = index == rvm.stopIndex ? rvm.timeTillStop(index) : rvm.timeForStop(index)
            cell.isLastCell = index == scheme.numberOfCells - 1 ? true : false
            cell.isSelected = index == rvm.stopIndex ? true : false
            cell.height = self.routeType == HopperBusRoutes.HB904 ? 65 : 55
        }

        scheme.selectionHandler = { (tableView, cell, selectedIndex) in
            if selectedIndex == self.routeViewModel.stopIndex { return }

            let animPoints = self.getAnimationTranslationPoints(tableView, selectedIndex: selectedIndex)
            (self.animTranslationStart, self.animTranslationFinish) = animPoints

            self.animateSelection()

            let oldIndexPath = NSIndexPath(forRow: self.routeViewModel.stopIndex , inSection: 0)
            if let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? StopTableViewCell {
                self.animatedCircleView.center = self.animTranslationStart
                self.view.addSubview(self.animatedCircleView)
                oldCell.isSelected = false
                let timeStr = self.routeViewModel.timeForStop(oldIndexPath.row)
                oldCell.animateTimeLabelTextChange(timeStr)
            }

            self.routeViewModel.stopIndex = selectedIndex
        }

        scheme.accordionConfigurationHandler = { (c, parentIndex) in
            let cell = c as StopTimesTableViewCell
            let rvm = self.routeViewModel
            let times = rvm.stopTimingsForStop(rvm.idForStop(parentIndex))
            cell.times = times
        }
        
        scheme.accordionSelectionHandler = { (c, selectedIndex) in
            return
        }
        
        dataSource = TableDataSource(scheme: scheme)
    }

    func getAnimationTranslationPoints(tableView: UITableView, selectedIndex: Int) -> (CGPoint!, CGPoint!) {
        let oldIndexPath = NSIndexPath(forRow: self.routeViewModel.stopIndex , inSection: 0)
        var start, finish: CGPoint

        if let oldCell = tableView.cellForRowAtIndexPath(oldIndexPath) as? StopTableViewCell {

            start = oldCell.convertPoint(oldCell.circleView.center, toView: view)

        } else {

            var cell: StopTableViewCell

            if selectedIndex > routeViewModel.stopIndex {
                // Animation Going Down
                let indexPath = tableView.indexPathsForVisibleRows()![1] as NSIndexPath
                cell = tableView.cellForRowAtIndexPath(indexPath)! as StopTableViewCell
            } else {
                // Animation Going Up On A Tuesday lol
                let visibleCellCount = tableView.indexPathsForVisibleRows()!.count
                let indexPath = tableView.indexPathsForVisibleRows()![visibleCellCount - 1] as NSIndexPath
                cell = tableView.cellForRowAtIndexPath(indexPath)! as StopTableViewCell
            }

            start = cell.convertPoint(cell.circleView.center, toView: self.view)
        }

        let newIndexPath = NSIndexPath(forRow: selectedIndex, inSection: 0)
        let newCell = tableView.cellForRowAtIndexPath(newIndexPath) as StopTableViewCell
        finish = newCell.convertPoint(newCell.circleView.center, toView: self.view)

        return (start, finish)
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension RouteViewController: UITableViewDelegate, TableViewDoubleTapDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let reuseIdentifier = dataSource.scheme.getReuseIdentifier(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        dataSource.scheme.handleSelection(tableView, cell: cell, withAbsoluteIndex: indexPath.row)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if dataSource.scheme.isAccordion(indexPath.row) {
            let parentIndex = dataSource.scheme.parentIndex
            return dataSource.scheme.accordionHeightHandler!(parentIndex: parentIndex)
        } else {
            return self.routeType == HopperBusRoutes.HB904 ? 65 : 55
        }
    }

    func tableView(tableView: TableView, didDoubleTapRowAtIndexPath indexPath: NSIndexPath) {
        dataSource.scheme.handleDoubleTap(tableView, withAbsoluteIndex: indexPath.row)
    }
}

// MARK: - POPAnimation Delegate

extension RouteViewController: POPAnimationDelegate {

    // MARK:- Animatons

    func animateSelection() {

        let anim = createScaleAnimation("scaleDown", from: 1.0, to: 0.5)
        animatedCircleView.layer.pop_addAnimation(anim, forKey: "scaleDown")
        view.userInteractionEnabled = false
    }

    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {

        if anim.name == "scaleDown" {

            let anim = createYTranslationAnimation("yTranslate", from: animTranslationStart, to: animTranslationFinish)
            animatedCircleView.pop_addAnimation(anim, forKey: "center")

        } else if anim.name == "yTranslate" {

            let anim = createScaleAnimation("scaleUp", from: 0.5, to: 1.0)
            animatedCircleView.layer.pop_addAnimation(anim, forKey: "scaleUp")

        } else {

            let indexPath = NSIndexPath(forRow: routeViewModel.stopIndex , inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as StopTableViewCell
            let timeStr = routeViewModel.timeTillStop(indexPath.row)
            cell.isSelected = true
            cell.animateTimeLabelTextChange(timeStr)

            animatedCircleView.removeFromSuperview()
            tableView.reloadData()

            view.userInteractionEnabled = true
        }
    }

    func createScaleAnimation(name: String, from start: CGFloat, to finish: CGFloat) -> POPSpringAnimation {
        let routeScaleXYAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        routeScaleXYAnim.name = name
        routeScaleXYAnim.delegate = self
        routeScaleXYAnim.springBounciness = 5
        routeScaleXYAnim.springSpeed = 18
        routeScaleXYAnim.fromValue = NSValue(CGSize: CGSizeMake(start, start))
        routeScaleXYAnim.toValue = NSValue(CGSize: CGSizeMake(finish, finish))
        return routeScaleXYAnim
    }

    func createYTranslationAnimation(name: String, from start: CGPoint, to final: CGPoint) -> POPBasicAnimation {
        let yTranslationAnimation = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        yTranslationAnimation.name = name
        yTranslationAnimation.delegate = self
        yTranslationAnimation.fromValue = NSValue(CGPoint: start)
        yTranslationAnimation.toValue = NSValue(CGPoint: final)
        return yTranslationAnimation
    }
}


