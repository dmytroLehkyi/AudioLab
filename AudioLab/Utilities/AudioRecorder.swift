//
//  AudioRecorder.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecorderDelegate: class {
    func audioRecorderDidFinishRecording(_ recorder: AudioRecorder)
}

class AudioRecorder: NSObject {

    private let recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder? = nil
    private let recordSettings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                AVSampleRateKey: 12000,
                          AVNumberOfChannelsKey: 1,
                       AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
    private var endDate: Date? = nil
    private var timer: Timer? = nil
    weak var delegate: AudioRecorderDelegate?

    func startObservingNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification, object: nil)
    }

    func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func record(to url: URL, till endDate: Date? = nil) {
        recordingSession.requestRecordPermission { [weak self] allowed in
            guard allowed, let self = self else { return }

            try? self.recordingSession.setCategory(.playAndRecord, mode: .default)
            try? self.recordingSession.setActive(true)
            self.startObservingNotifications()

            if let recorder = try? AVAudioRecorder(url: url, settings: self.recordSettings) {
                recorder.delegate = self
                self.audioRecorder = recorder
                self.audioRecorder?.record()
                if let secondsTillEnd = endDate?.timeIntervalSince(Date()) {
                    self.timer = Timer.scheduledTimer(withTimeInterval: secondsTillEnd, repeats: false) { [weak self] timer in
                        self?.stop()
                    }
                }
            }
        }
    }

    func pause() {
        audioRecorder?.pause()
    }

    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopObservingNotifications()
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        switch type {
        case .began:
            audioRecorder?.pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                audioRecorder?.record()
            }
        default: break
        }
    }
}

//MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.audioRecorderDidFinishRecording(self)
    }
}
