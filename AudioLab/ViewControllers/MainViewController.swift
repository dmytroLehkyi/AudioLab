//
//  MainViewController.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/8/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    //MARK: - Public types

    enum State {
        case idle
        case playing
        case recording
        case paused
        case alarm
    }

    //MARK: - Public properties

    var state: State = .idle {
        didSet {
            previousState = oldValue
            didMove(to: state)
        }
    }

    //MARK: - Private properties

    private var previousState: State = .idle

    //MARK: - Outlets

    @IBOutlet private(set) var statusLabel: UILabel!
    @IBOutlet private(set) var actionButton: UIButton!

    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    //MARK: - Actions

    @IBAction func actionButtonPressed(_ sender: Any) {
        if [.recording, .playing].contains(state) {
            state = .paused
        } else {
            moveToNextState()
        }
    }

    //MARK: - Private methods

    private func setupUI() {
        actionButton.clipsToBounds = true
        actionButton.layer.cornerRadius = 5
        actionButton.setTitle("Play", for: .normal)
        statusLabel.text = "Idle"
    }

    private func moveToNextState() {
        switch state {
        case .idle: state = .playing
        case .playing: state = .recording
        case .paused: state = previousState
        case .recording: state = .alarm
        case .alarm: state = .idle
        }
    }

    private func didMove(to state: State) {
        switch state {
        case .idle: didMoveToIdleState()
        case .playing: didMoveToPlayingState()
        case .paused: didMoveToPausedState()
        case .recording: didMoveToRecordingState()
        case .alarm: didMoveToAlarmState()
        }
    }

    private func didMoveToIdleState() {
        actionButton.setTitle("Play", for: .normal)
        statusLabel.text = "Idle"
    }

    private func didMoveToPlayingState() {
        actionButton.setTitle("Pause", for: .normal)
        statusLabel.text = "Playing"
    }

    private func didMoveToRecordingState() {
        actionButton.setTitle("Pause", for: .normal)
        statusLabel.text = previousState == .playing ? "Playing" : "Recording"
    }

    private func didMoveToPausedState() {
        actionButton.setTitle("Play", for: .normal)
        statusLabel.text = "Paused"
    }

    private func didMoveToAlarmState() {
        actionButton.setTitle("Play", for: .normal)
        statusLabel.text = "Alarm"
    }
}

