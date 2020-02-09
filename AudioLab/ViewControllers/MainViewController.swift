//
//  MainViewController.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/8/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    //MARK: - Outlets

    @IBOutlet private(set) var statusLabel: UILabel!
    @IBOutlet private(set) var actionButton: UIButton!

    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    //MARK: - Private methods

    private func setupUI() {
        actionButton.clipsToBounds = true
        actionButton.layer.cornerRadius = 5
        actionButton.setTitle("Play", for: .normal)
        statusLabel.text = "Idle"
    }
}

