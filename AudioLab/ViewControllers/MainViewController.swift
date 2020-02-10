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
    @IBOutlet private(set) var sleepingTimerButton: UIButton!
    @IBOutlet private(set) var alarmButton: UIButton!
    @IBOutlet private(set) var recordSleepSwitch: UISwitch!

    //MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.clipsToBounds = true
        actionButton.layer.cornerRadius = 5
        updateUI()

        loadDataFromSettings()
        startObservingNotifications()

        notificationsPermissions.requestAuthorization { _ in }
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

    @IBAction func selectTimer(_ sender: Any) {
        presentSleepDurationAlert()
    }

    @IBAction func selectAlarm(_ sender: Any) {
        presentAlarmTimePicker()
    }

    @IBAction func recordSleepToggle(_ sender: Any) {
        settings.shouldRecordSleeping = recordSleepSwitch.isOn
    }
    //MARK: - Private methods

    private func loadDataFromSettings() {
        sleepingTimerButton.setTitle(displayedValue(for: settings.sleepDurationInSeconds), for: .normal)
        alarmButton.setTitle(settings.alarmTime, for: .normal)
        recordSleepSwitch.setOn(settings.shouldRecordSleeping, animated: false)
    }

    private func moveToNextState() {
        switch state {
        case .idle: (settings.sleepDurationInSeconds) > 0 ? (state = .playing) : (state = .recording)
        case .playing : state = .recording
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
        enableSettingsSelection(true)
    }

    private func didMoveToPlayingState() {
        guard let player = soundPlayer  else {
            state = previousState
            return
        }
        enableSettingsSelection(false)

        if previousState == .idle {
            scheduleAlarm()
            player.play(duration: 5)//settings.sleepDurationInSeconds)

            if shouldRecordSleeping {
                tmpRecorder?.record(to: FileManager.default.temporaryDocumentURL("tmp"))
            }
        } else {
            player.resume()
        }
    }

    private func didMoveToPausedState() {
        enableSettingsSelection(false)
        if previousState == .playing {
            soundPlayer?.pause()
        } else {
            audioRecorder?.pause()
        }
    }

    private func didMoveToRecordingState() {
        if settings.shouldRecordSleeping {
            let fileManager = FileManager.default
            fileManager.createSleepRecordingsFolderIfNeeded()

            audioRecorder?.record(to: fileManager.generateSleepRecordingURL(), till: Date.nextDate(matching: settings.alarmTime))
            tmpRecorder?.stop()
        }
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

    private func presentAlarmTimePicker() {
        let vc = TimePickerViewController.loadFromStoryboard()

        vc.configure(with: settings.alarmTime)
        vc.onComplete = { [weak self] date in
            self?.settings.alarmTime = date
            self?.loadDataFromSettings()
        }

        present(vc, animated: true) 
    }

    private func presentSleepDurationAlert() {
        let alert = UIAlertController(title: "Sleep Timer", message: nil, preferredStyle: .actionSheet)
        let availableSleepDurationsInSeconds = [0, 60, 5 * 60, 10 * 60, 15 * 60, 20 * 60]

        availableSleepDurationsInSeconds.forEach { duration in
            alert.addAction(UIAlertAction(title: displayedValue(for: duration), style: . default){ action in
                self.settings.sleepDurationInSeconds = duration
                self.loadDataFromSettings()

            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alert, animated: true)
    }

    private func displayedValue(for sleepDuration: Int) -> String {
        return sleepDuration > 0 ? "\(sleepDuration / 60) min" : "off"
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

    private func enableSettingsSelection(_ enable: Bool) {
        sleepingTimerButton.isEnabled = enable
        alarmButton.isEnabled = enable
        recordSleepSwitch.isEnabled = enable
    }

    var shouldRecordSleeping: Bool {
        return (recordingPermissions.authorizationStatus == .granted) && settings.shouldRecordSleeping
    }

    private func startObservingNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(moveToForeground),
                name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func moveToForeground(notification: Notification) {
        if Date.isCurrentTimeEqual(to: settings.alarmTime) && state != .idle {
            state = .alarm
        }
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
