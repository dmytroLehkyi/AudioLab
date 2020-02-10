//
//  DateFormatter+Extensions.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/10/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var shortTimeFormatter: DateFormatter {
        let formater = DateFormatter()
        formater.locale = Locale(identifier: "en_US_POSIX")
        formater.dateFormat = "hh:mm a"
        return formater
    }
}
