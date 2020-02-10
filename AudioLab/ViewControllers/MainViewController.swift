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

    private lazy var soundPlayer: AudioPlayer? = {
        var audioPlayer = AudioPlayer(sound: .nature)
        audioPlayer?.delegate = self
        return audioPlayer
    }()

    private lazy var alarmPlayer: AudioPlayer? = {
        var audioPlayer = AudioPlayer(sound: .alarm)
        audioPlayer?.delegate = self
        return audioPlayer
    }()

    private let recordingPermissions: RecordingPermissionsProviding = RecordingPermissions()
    private let notificationsPermissions: UserNotificationsPermissionsProviding = UserNotificationsPermissions()
    private let notiifcationsManager = UserNotificationsManager()
    private var needsToDisplayAlarm = false
    private lazy var audioRecorder: AudioRecorder? = {
        let recorder = AudioRecorder()
        recorder.delegate = self
        return recorder
    }()

    // We need this temorary recorder to start recording simultaniously with audio playing.
    // It's workaround for issue when AVAudioRecorder cannot start recording when app is in background
    private var tmpRecorder: AudioRecorder? = AudioRecorder()

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

        notificationsPermissions.requestAuthorization { _ in
        }
    }

    //MARK: - Actions

    @IBAction func actionButtonPressed(_ sender: Any) {
        if [.recording, .playing].contains(state) {
            state = .paused
        } else {
            recordingPermissions.requestAccess { [weak self] _ in
                DispatchQueue.main.async {
                    self?.moveToNextState()
                }
            }
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
        guard let player = soundPlayer  else {
            state = previousState
            return
        }

        if previousState == .idle {
            scheduleAlarm()
            player.play(duration: 5 /*settings.sleepDurationInSeconds*/)

            if recordingPermissions.authorizationStatus == .granted {
                tmpRecorder?.record(to: FileManager.default.temporaryDocumentURL("tmp"))
            }
        } else {
            player.resume()
        }
    }

    private func didMoveToPausedState() {
        if previousState == .playing {
            soundPlayer?.pause()
        }
    }

    private func didMoveToRecordingState() {
        let fileManager = FileManager.default
        fileManager.createSleepRecordingsFolderIfNeeded()

        audioRecorder?.record(to: fileManager.generateSleepRecordingURL(), till: Date.nextDate(matching: settings.alarmTime))
        tmpRecorder?.stop()
    }

    private func didMoveToAlarmState() {
        alarmPlayer?.play()
        presentAlarm()
    }

    private func presentAlarm() {
        let alert = UIAlertController(title: "Alarm", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Off", style: .default) { _ in
            self.alarmPlayer?.stop()
            self.state = .idle
        })
        present(alert, animated: true) { }
    }

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

    private func scheduleAlarm() {
        guard let alarmDate = Date.nextDate(matching: settings.alarmTime) else {
            return
        }
        notiifcationsManager.scheduleNotification(with: "Alert", at: alarmDate)
    }
}

//MARK: - AudioPlayerDelegate

extension MainViewController: AudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AudioPlayer) {
        if recordingPermissions.authorizationStatus == .granted && player === soundPlayer {
            state = .recording
        }
    }
}

//MARK: - AudioRecorderDelegate

extension MainViewController: AudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AudioRecorder) {
        if recorder === audioRecorder {
            state = .alarm
        }
    }
}
