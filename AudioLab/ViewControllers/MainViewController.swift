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
            updateUI()
            didMove(to: state)
        }
    }

    //MARK: - Private properties

    private lazy var player: AudioPlayer? = {
        var audioPlayer = AudioPlayer(sound: .nature)
        audioPlayer?.delegate = self
        return audioPlayer
    }()
    private var previousState: State = .idle
    private var settings = Settings()
    private var actionButtonTitle: String {
        get {
            return actionButton.title(for: .normal) ?? ""
        }
        set {
            actionButton.setTitle(newValue, for: .normal)
        }
    }
    private var statusLabelTitle: String {
        get {
            return statusLabel.text ?? ""
        }
        set {
            statusLabel.text = newValue
        }
    }

    //MARK: - Outlets

    @IBOutlet private(set) var statusLabel: UILabel!
    @IBOutlet private(set) var actionButton: UIButton!

    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        actionButton.clipsToBounds = true
        actionButton.layer.cornerRadius = 5
        updateUI()
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

    private func didMoveToIdleState() {}

    private func didMoveToPlayingState() {
        guard let player = player  else {
            state = previousState
            return
        }

        if previousState == .idle {
            player.play(duration: settings.sleepDurationInSeconds)
        } else {
            player.resume()
        }
    }

    private func didMoveToPausedState() {
        if previousState == .playing {
            player?.pause()
        }
    }

    private func didMoveToRecordingState() {}

    private func didMoveToAlarmState() {}

    private func updateUI() {
        switch state {
        case .idle:
            actionButtonTitle = "Play"
            statusLabelTitle = "Idle"
        case .playing:
            actionButtonTitle = "Pause"
            statusLabelTitle = "Playing"
        case .paused where previousState == .playing:
            actionButtonTitle = "Play"
            statusLabelTitle = "Paused"
        case .paused where previousState == .recording:
            actionButtonTitle = "Record"
            statusLabelTitle = "Paused"
        case .recording:
            actionButtonTitle = "Pause"
            statusLabelTitle = "Recording"
        case .alarm:
            actionButtonTitle = "Play"
            statusLabelTitle = "Alarm"
        default:
            break
        }
    }
}

//MARK: - AudioPlayerDelegate

extension MainViewController: AudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AudioPlayer) {
        state = .recording
    }
}
