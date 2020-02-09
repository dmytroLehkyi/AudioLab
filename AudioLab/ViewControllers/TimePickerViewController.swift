//
//  TimePickerViewController.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    var onComplete: ((String) -> ())? = nil
    private var timeString: String = ""

    func configure(with timeString: String) {
        self.timeString = timeString
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        onComplete?(dateFormatter.string(from: datePicker.date))

        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let date = dateFormatter.date(from: timeString) ?? Date()
        datePicker.setDate(date, animated: false)
    }

    private var dateFormatter: DateFormatter {
        let formater = DateFormatter()
        formater.timeStyle = .short

        return formater
    }
}
