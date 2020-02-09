//
//  SettingsTableViewController.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
        addTopSeparatorLine()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        if let settingsCell = cell as? SettingsTableViewCell {
            settingsCell.configure(with: "Title", value: "Value")
        }

        return cell
    }

    //MARK: - Private methods

    private func addTopSeparatorLine() {
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
    }
}
