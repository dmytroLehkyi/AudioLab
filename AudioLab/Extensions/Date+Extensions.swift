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

//        let formater = DateFormatter()
//
//        formater.locale = Locale(identifier: "en_US_POSIX")
//        formater.dateFormat = "hh:mm a"

//
//
//
//        //formater.dateFormat = "hh:mm"
//        //formater.locale = Locale(identifier: "en_US")
////        formater.timeStyle = .short
//        let str = dateFormatter.string(from: Date())
////
////
//        let comp = DateComponents()
//
//
//        //formater.timeZone = .current
//        let d = dateFormatter.date(from: str)
//        print(d)

        guard let date = DateFormatter.shortTimeFormatter.date(from: time) else {
            return nil
        }


        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
    }
}
