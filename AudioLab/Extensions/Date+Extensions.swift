//
//  Date+Extensions.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/10/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation

extension Date {
    static func nextDate(matching time: String) -> Date? {
        guard let date = DateFormatter.shortTimeFormatter.date(from: time) else {
            return nil
        }

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
    }

    static func isCurrentTimeEqual(to time: String) -> Bool {
        guard let timeToCompare = Date.nextDate(matching: time) else {
            return false
        }

        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: timeToCompare)
        let currentTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())

        return currentTimeComponents.hour == timeComponents.hour && currentTimeComponents.minute == timeComponents.minute
    }
}
