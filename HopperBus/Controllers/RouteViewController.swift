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

    lazy var routeHeaderView: RouteHeaderView = {
        let view = RouteHeaderView()
        view.titleLabel.text = self.routeType.title.uppercaseString
        return view
    }()

    lazy var tableView: TableView = {
        let tableView = TableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleTapDelegate = self
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 64.0, 0.0);
        tableView.registerClass(StopTableViewCell.self, forCellReuseIdentifier: "cell")
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

        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = self.routeType == HopperBusRoutes.HB904 ? 65 : 55
    }
}

// MARK: - TableViewDataSource & Delegate Methods

extension RouteViewController: UITableViewDelegate, UITableViewDataSource, TableViewDoubleTapDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return routeHeaderView
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeViewModel.numberOfStopsForCurrentRoute()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.routeType == HopperBusRoutes.HB904 ? 65 : 55
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as StopTableViewCell
        let rvm = self.routeViewModel
        let index = indexPath.row

        cell.titleLabel.text = rvm.nameForStop(index)
        cell.timeLabel.text = index == rvm.stopIndex ? rvm.timeTillStop(index) : rvm.timeForStop(index)
        cell.isLastCell = index == rvm.numberOfStopsForCurrentRoute() - 1 ? true : false
        cell.isSelected = index == rvm.stopIndex ? true : false
        cell.height = self.routeType == HopperBusRoutes.HB904 ? 65 : 55
        // get cell height to autolayout stuff

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let selectedIndex = indexPath.row

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

    func tableView(tableView: TableView, didDoubleTapRowAtIndexPath indexPath: NSIndexPath) {
        let rvm = self.routeViewModel
        let times = rvm.stopTimingsForStop(rvm.idForStop(indexPath.row))
        let timesViewController = TimesViewController()
        timesViewController.times = times
        timesViewController.modalPresentationStyle = .Custom
        timesViewController.transitioningDelegate = self
        presentViewController(timesViewController, animated: true, completion:nil)
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

// MARK: - Transitioning Delegate

extension RouteViewController: UIViewControllerTransitioningDelegate {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTimesTransistionManager()
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTimesTransistionManager()
    }
}


