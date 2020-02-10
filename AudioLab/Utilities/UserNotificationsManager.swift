//
//  UserNotificationsManager.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/10/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation
import UserNotifications

class UserNotificationsManager {
    func scheduleNotification(with title: String, at date: Date) {

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound(named: UNNotificationSoundName("sound.caf"))

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }

}
