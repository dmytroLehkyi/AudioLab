//
//  AppDelegate.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/8/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }
}

