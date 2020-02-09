//
//  SettingsTableViewController.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - Public types

    enum RowType {
        case sleepDuration
        case alarmTime
    }

    struct Row {
        var type: RowType
        var title: String
        var value: String
    }

    // MARK: - Private properties

    private let settings = Settings()
    private var rows: [Row] = []

    // MARK: - Public

    func title(for indexPath: IndexPath) -> String {
        return rows[indexPath.row].title
    }

    func value(for indexPath: IndexPath) -> String {
        return rows[indexPath.row].value
    }

    func rowType(at indexPath: IndexPath) -> RowType {
        let row = rows[indexPath.row]
        return row.type
    }

    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
        startObservingNotifications()
        addTopSeparatorLine()
        loadData()
    }

    //MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        if let settingsCell = cell as? SettingsTableViewCell {
            settingsCell.configure(with: viewModelForCell(at: indexPath))
        }

        return cell
    }

    //MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch rowType(at: indexPath) {
        case .alarmTime: presentAlarmTimePicker()
        case .sleepDuration: presentSleepDurationAlert()
        }
    }

    //MARK: - Private methods

    private func loadData() {
        rows = [Row(type: .sleepDuration,
                   title: "Sleep timer",
                   value: displayedValue(for: settings.sleepDurationInSeconds)),
                Row(type: .alarmTime,
                   title: "Alarm",
                   value: self.settings.alarmTime)]
    }

    private func presentAlarmTimePicker() {
        let vc = TimePickerViewController.loadFromStoryboard()

        vc.configure(with: settings.alarmTime)
        vc.onComplete = { [weak self] date in
            self?.settings.alarmTime = date
        }

        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }

    private func presentSleepDurationAlert() {
        let alert = UIAlertController(title: "Sleep Timer", message: nil, preferredStyle: .actionSheet)
        let availableSleepDurationsInSeconds = [0, 60, 5 * 60, 10 * 60, 15 * 60, 20 * 60]

        availableSleepDurationsInSeconds.forEach { duration in
            alert.addAction(UIAlertAction(title: displayedValue(for: duration), style: . default){ action in
                self.settings.sleepDurationInSeconds = duration
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    private func addTopSeparatorLine() {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }

    private func displayedValue(for sleepDuration: Int) -> String {
        return sleepDuration > 0 ? "\(sleepDuration / 60) min" : "off"
    }

    private func startObservingNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged), name: .settingsChanged, object: nil)
    }

    private func viewModelForCell(at indexPath: IndexPath) -> SettingsTableViewCell.ViewModel {

        return SettingsTableViewCell.ViewModel(title: title(for: indexPath),
                                               value: value(for: indexPath))
    }

    @objc func settingsChanged(notification: Notification) {
        loadData()
        tableView.reloadData()
    }
}
