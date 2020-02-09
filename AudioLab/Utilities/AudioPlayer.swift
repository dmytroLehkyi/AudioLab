//
//  AudioPlayer.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPlayerDelegate: class {
    func audioPlayerDidFinishPlaying(_ player: AudioPlayer)
}

class AudioPlayer {

    //MARK: - Public types

    enum Sound: String {
        case nature
        case alarm
    }

    //MARK: - Private properties

    private let player: AVAudioPlayer
    private var timer: Timer? = nil
    private var remainingTimeInterval: TimeInterval = .zero

    //MARK: - Public properties

    weak var delegate: AudioPlayerDelegate?

    //MARK: - Initializers

    init?(sound: Sound) {
        guard let dataAsset = NSDataAsset(name: sound.rawValue) else {
            return nil
        }

        do {
            player = try AVAudioPlayer(data: dataAsset.data)
            player.numberOfLoops = -1
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            return nil
        }
    }

    //MARK: - Public

    func play(duration: Int) {
        guard !player.isPlaying else { return }

        startObservingNotifications()
        player.play()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { [weak self] timer in
            self?.stop()
        }
    }

    func pause() {
        guard player.isPlaying else {
            return
        }

        if let timer = timer {
            remainingTimeInterval = timer.fireDate.timeIntervalSince(Date())
        }

        timer?.invalidate()
        timer = nil

        player.pause()
    }

    func resume() {
        play(duration: Int(remainingTimeInterval))
    }

    func stop() {
        player.stop()
        stopObservingNotifications()
        delegate?.audioPlayerDidFinishPlaying(self)
    }

    //MARK: - Private

    private func startObservingNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification, object: nil)
    }

    private func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        switch type {
        case .began:
            player.pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                player.play()
            }
        default: break
        }
    }
}
