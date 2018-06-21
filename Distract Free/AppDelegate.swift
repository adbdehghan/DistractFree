//
//  AppDelegate.swift
//  Distract Free
//
//  Created by adb on 2/3/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import SwiftLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        GMSServices.provideAPIKey("AIzaSyAKoZxownJnAdIayjsIiu9n488xfJWsnlw")
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        if let _ = launchOptions?[UIApplicationLaunchOptionsKey.location] {
            Locator.subscribeSignificantLocations(onUpdate: { newLocation in
                // This block will be executed with the details of the significant location change that triggered the background app launch,
                // and will continue to execute for any future significant location change events as well (unless canceled).
            }, onFail: { (err, lastLocation) in
                // Something bad has occurred
            })
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        Locator.requestAuthorizationIfNeeded(.always)
//        
//        Locator.subscribeSignificantLocations(onUpdate:{ loc in
//            
//            let speed = Double((loc.speed))
//            print("Speed: \(speed)")
//            
//            
//        },onFail: { err, last in
//            print("Failed with error: \(err)")
//        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

