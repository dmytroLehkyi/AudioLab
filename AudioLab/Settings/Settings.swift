//
//  Settings.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation

struct AlartmTime {
    var hours = 0
    var minutes = 0
}


extension Notification.Name {
    static let settingsChanged = Notification.Name("SettingsChanged")
}

class Settings {

    //MARK: - Private properties

    private let defaultSleepDurationInSeconds = 5 * 60
    private let defaultAlarmTime = "7:00 AM"

    private let sleepDurationKey = "audiolab.settings.sleepduration"
    private let alarmTimeKey = "audiolab.settings.alarmtime"

    private let userDefaults: UserDefaults = .standard
    private let notificationCenter: NotificationCenter = .default

    //MARK: - Public properties

    var sleepDurationInSeconds: Int {
        get {
            guard
                let storedValue = userDefaults.value(forKey: sleepDurationKey) as? Int else {
                return defaultSleepDurationInSeconds
            }
            return storedValue
        }

        set {
            userDefaults.set(newValue, forKey: sleepDurationKey)
            notificationCenter.post(name: .settingsChanged, object: nil, userInfo: nil)
        }
    }

    var alarmTime: String {
        get {
            guard
                let storedValue = userDefaults.value(forKey: alarmTimeKey) as? String else {
                return defaultAlarmTime
            }
            return storedValue
        }

        set {
            userDefaults.set(newValue, forKey: alarmTimeKey)
            notificationCenter.post(name: .settingsChanged, object: nil, userInfo: nil)
        }
    }
}

