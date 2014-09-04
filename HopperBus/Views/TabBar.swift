//
//  TabBar.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 27/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit


@objc protocol TabBarDelegate {
    func tabBar(tabBar: TabBar, didSelectItem item: TabBarItem, withTag tag: Int)
}

class TabBar: UIView {

     // MARK: - Properties

    var tabBarItemCount: Int
    var currentTabBarItem: TabBarItem?
    weak var delegate: TabBarDelegate?

    var visualFormatForHorizontalConstrints: String {
        var vflString = "H:|"
        for i in 1...tabBarItemCount {
            vflString += "[tabBarItem\(i)]"
        }
        return vflString
    }

    // MARK: - Initializers

    required init(coder aDecoder: NSCoder) {
        tabBarItemCount = 0
        super.init(coder: aDecoder)
    }

    init(options: [String: AnyObject]) {
        tabBarItemCount = options["tabCount"]! as Int
        super.init(frame: CGRectZero)

        let buttonTitles: [String] = options["titles"]! as [String]

        var views: [String: TabBarItem] = [String: TabBarItem]()

        for i in 0..<tabBarItemCount {
            let tabItem = TabBarItem(title: buttonTitles[i])
            tabItem.tag = i
            tabItem.setTranslatesAutoresizingMaskIntoConstraints(false)
            tabItem.addTarget(self, action: "onTap:", forControlEvents: .TouchUpInside)
            views["tabBarItem\(i+1)"] = tabItem
            addSubview(tabItem)
        }

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[tabBarItem1]|", options: nil, metrics: nil, views:views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(visualFormatForHorizontalConstrints, options: .AlignAllCenterY, metrics: nil, views:views))

        currentTabBarItem = views["tabBarItem1"]
        currentTabBarItem!.selected = true
    }

    // MARK: - Actions

    func onTap(sender: AnyObject) {
        var clickedTabBarItem = sender as TabBarItem

        if currentTabBarItem! == clickedTabBarItem {
            return;
        }

        clickedTabBarItem.selected = !clickedTabBarItem.selected
        currentTabBarItem!.selected = false
        currentTabBarItem = clickedTabBarItem

        self.delegate?.tabBar(self, didSelectItem: clickedTabBarItem, withTag: clickedTabBarItem.tag)
    }

    // MARK: - Autolayout Overrides

    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(320, 49);
    }
}
