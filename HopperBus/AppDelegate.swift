//
//  AppDelegate.swift
//  HopperBus
//
//  Created by Tosin Afolabi on 22/08/2014.
//  Copyright (c) 2014 Tosin Afolabi. All rights reserved.
//

import UIKit
import Parse
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var homeViewController: HomeViewController = {
        let homeViewController = HomeViewController()
        return homeViewController
    }()
                            
    lazy var window: UIWindow? = {

        let win = UIWindow(frame: UIScreen.mainScreen().bounds)
        win.backgroundColor = UIColor.whiteColor()
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(kHasRouteDataBeenStoredInDocuments) {
            
            let jsonFilePath = NSBundle.mainBundle().pathForResource("Routes", ofType: "json")!
            guard let data = NSData(contentsOfFile: jsonFilePath) else {
                fatalError("Routes JSON File could not be read.")
            }
            
            let p = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
            let path = p.stringByAppendingPathComponent("routeData")
            data.writeToFile(path, atomically: false)
            
            let json = JSON(data: data)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kHasRouteDataBeenStoredInDocuments)
            NSUserDefaults.standardUserDefaults().setFloat(json["version"].float ?? 1.0, forKey: kDataStoreVersion)
        }

        if NSUserDefaults.standardUserDefaults().boolForKey(kHasHomeViewBeenDisplayedYetKey) {
            win.rootViewController = UINavigationController(rootViewController: self.homeViewController)
        } else {
            win.rootViewController = UINavigationController(rootViewController: OnboardingViewController())
        }

        return win
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        setupStyle()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        window?.makeKeyAndVisible()

        // Register for remote notifications
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        Parse.setApplicationId("PLKK3ArZhBTROcCinEB5J6qeMwUkTrZL9P7U9XRf", clientKey: "94CjREf1puBASWRROTeNCJuzR6nmtyiK4tfGm9qN")

        // Google Analytics

        GAI.sharedInstance().trackUncaughtExceptions = true
        GAI.sharedInstance().dispatchInterval = 20
        GAI.sharedInstance().logger.logLevel = .None
        GAI.sharedInstance().trackerWithTrackingId("UA-46757742-8")

        return true
    }

    func setupStyle() {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
        UINavigationBar.appearance().barTintColor = UIColor.HopperBusBrandColor()
        UINavigationBar.appearance().translucent = true
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Montserrat", size: 18.0)!]
    }

    func applicationDidBecomeActive(application: UIApplication) {
        homeViewController.routeViewModelContainer.updateScheduleIndexForRoutes()
    }

    func applicationWillResignActive(application: UIApplication) {
        homeViewController.saveCurrentRoute()
    }

    func applicationWillTerminate(application: UIApplication) {
        homeViewController.saveCurrentRoute()
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if let query = url.query where query.characters.count > 0 {
            
            let parameters = parseURLQuery(query)
            guard let route = parameters["route"] else {
                print("Route Argument Not Passed")
                return true
            }
            
            switch route {
            case "901", "902", "903", "904", "RT":
                let hbRoute = HopperBusRoutes.routeCodeToEnum(route)
                homeViewController.showTab(hbRoute.rawValue)
                homeViewController.tabBar.selectedIndex = hbRoute.rawValue
                break
            default:
                break
            }
        }
        
        return true
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
    
    // MARK: - Helper Methods
    
    func parseURLQuery(query: String) -> [String: String] {
        
        var parameters = [String: String]()
        let components = query.characters.split {$0 == "&"}.map { String($0) }
        for c in components {
            let subComponents = c.characters.split {$0 == "="}.map { String($0) }
            if subComponents.count == 2 {
                parameters[subComponents[0]] = subComponents[1]
            }
        }
        return parameters
    }
}
