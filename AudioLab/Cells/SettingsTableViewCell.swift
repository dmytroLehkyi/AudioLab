//
//  SettingsTableViewCell.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    //MARK: - Outlets

    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var valueLabel: UILabel!

    //MARK: - Public

    func configure(with title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
