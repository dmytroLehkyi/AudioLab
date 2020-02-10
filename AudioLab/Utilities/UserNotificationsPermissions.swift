//
//  UserNotificationsPermissions.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/10/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation
import UserNotifications

protocol UserNotificationsPermissionsProviding {
    func requestAuthorization(completionHandler: @escaping (Bool) -> Void)
}

class UserNotificationsPermissions: UserNotificationsPermissionsProviding {
    let userNotificationsCenter = UNUserNotificationCenter.current()

    func requestAuthorization(completionHandler: @escaping (Bool) -> Void) {
        userNotificationsCenter.requestAuthorization(options: [.alert, .sound]) { (result, _) in
            completionHandler(result)
        }
    }
}
