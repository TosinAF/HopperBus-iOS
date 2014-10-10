//
//  AppDelegate.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var homeViewController: RootViewController = {
        let homeViewController = RootViewController()
        return homeViewController
    }()
                            
    lazy var window: UIWindow = {
        let win = UIWindow(frame: UIScreen.mainScreen().bounds)
        win.backgroundColor = UIColor.blackColor()
        win.rootViewController = UINavigationController(rootViewController: self.homeViewController)
        return win
    }()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        setupStyle()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        window.makeKeyAndVisible()
        return true
    }

    func setupStyle() {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        UINavigationBar.appearance().barTintColor = UIColor.HopperBusBrandColor()
        if iOS8 { UINavigationBar.appearance().translucent = true }
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "Montserrat", size: 18.0)]
    }

    func applicationWillResignActive(application: UIApplication!) {
        homeViewController.saveCurrentRoute()
    }

    func applicationWillTerminate(application: UIApplication!) {
        homeViewController.saveCurrentRoute()
    }
}
