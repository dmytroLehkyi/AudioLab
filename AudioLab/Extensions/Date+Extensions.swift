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
}
