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

    lazy var homeViewController: HomeViewController = {
        let homeViewController = HomeViewController()
        return homeViewController
    }()
                            
    lazy var window: UIWindow = {

        let win = UIWindow(frame: UIScreen.mainScreen().bounds)
        win.backgroundColor = UIColor.whiteColor()

        if NSUserDefaults.standardUserDefaults().boolForKey(kHasHomeViewBeenDisplayedYetKey) {
            win.rootViewController = UINavigationController(rootViewController: self.homeViewController)
        } else {
            win.rootViewController = UINavigationController(rootViewController: OnboardingViewController())
        }

        return win
    }()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

        setupStyle()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        window.makeKeyAndVisible()

        // Register for remote notifications

        if iOS8 {
            let userNotificationTypes: UIUserNotificationType = .Alert | .Badge | .Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let remoteNotificationTypes: UIRemoteNotificationType = .Alert | .Badge | .Sound
            application.registerForRemoteNotificationTypes(remoteNotificationTypes)
        }

        Parse.setApplicationId("PLKK3ArZhBTROcCinEB5J6qeMwUkTrZL9P7U9XRf", clientKey: "94CjREf1puBASWRROTeNCJuzR6nmtyiK4tfGm9qN")

        // Google Analytics

        GAI.sharedInstance().trackUncaughtExceptions = true
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().logger.logLevel = .Info
        GAI.sharedInstance().trackerWithTrackingId("UA-46757742-8")

        return true
    }

    func setupStyle() {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        UINavigationBar.appearance().barTintColor = UIColor.HopperBusBrandColor()
        if iOS8 { UINavigationBar.appearance().translucent = true }
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Montserrat", size: 18.0)!]
    }

    func applicationDidBecomeActive(application: UIApplication) {
        homeViewController.routeViewModelContainer.updateScheduleIndexForRoutes()
    }

    func applicationWillResignActive(application: UIApplication!) {
        homeViewController.saveCurrentRoute()
    }

    func applicationWillTerminate(application: UIApplication!) {
        homeViewController.saveCurrentRoute()
    }

    // MARK: - Push Notifications

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock(nil)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
}
