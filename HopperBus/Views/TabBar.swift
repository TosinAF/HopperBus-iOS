//
//  TabBar.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

@objc protocol TabBarDelegate {
    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, atIndex index: Int)
}

class TabBar: UIView {

    // MARK: - Properties

    var selectedIndex = 0
    var tabBarItems: [TabBarItem] = []
    var numberOfTabBarItems: Int {
        return tabBarItems.count
    }

    weak var delegate: TabBarDelegate?

    var visualFormatForHorizontalConstrints: String {
        var vflString = "|"
        for i in 1...numberOfTabBarItems {
            vflString += "[tabBarItem\(i)]"
        }
        return vflString
    }

    let imageTitle: String?
    let imageTabBarIndex = 2

    // MARK: - Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(options: [String: AnyObject]) {
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.whiteColor()

        var views = [String: TabBarItem]()

        let buttonTitles: [String] = options["titles"]! as [String]
        let count = options["tabBarItemCount"]! as Int

        let tabWidth = Int(UIScreen.mainScreen().bounds.size.width) / count

        if let title: AnyObject = options["image"] {
            imageTitle = title as? String
        }

        for i in 0..<count {

            var tabItem: TabBarItem

            if i == imageTabBarIndex && imageTitle != nil {
                tabItem = TabBarItem(image: UIImage(named: imageTitle!)!)
            } else {
                tabItem = TabBarItem(title: buttonTitles[i])
            }

            tabItem.tag = i
            tabItem.width = CGFloat(tabWidth)
            tabItem.setTranslatesAutoresizingMaskIntoConstraints(false)
            tabItem.addTarget(self, action: "onTap:", forControlEvents: .TouchUpInside)
            views["tabBarItem\(i+1)"] = tabItem
            tabBarItems.append(tabItem)
            addSubview(tabItem)
        }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[tabBarItem1]|", options: nil, metrics: nil, views:views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(visualFormatForHorizontalConstrints, options: .AlignAllCenterY, metrics: nil, views:views))

        tabBarItems[selectedIndex].selected = true
    }

    // MARK: - Actions

    func onTap(sender: AnyObject) {
        var clickedTabBarItem = sender as TabBarItem

        /*if selectedIndex == clickedTabBarItem.tag {
            return;
        }*/

        setSelectedIndex(clickedTabBarItem.tag)
        self.delegate?.tabBar(self, didSelectItem: clickedTabBarItem, atIndex: clickedTabBarItem.tag)
    }

    // MARK: - State Methods

    func setSelectedIndex(index:Int) {
        let previousTabBarItem = tabBarItems[selectedIndex]
        let newTabBarItem = tabBarItems[index]

        selectedIndex = index
        previousTabBarItem.selected = false
        newTabBarItem.selected = true
    }

    // MARK: - Autolayout Overrides

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, 49);
    }
}
