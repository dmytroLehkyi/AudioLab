//
//  RecordingPermissions.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/10/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation
import AVFoundation

protocol RecordingPermissionsProviding {
    var authorizationStatus: AVAudioSession.RecordPermission { get }
    func requestAccess(completionHandler: @escaping (Bool) -> Void)
}


class RecordingPermissions: RecordingPermissionsProviding {
    private let recordingSession: AVAudioSession = AVAudioSession.sharedInstance()

    func requestAccess(completionHandler: @escaping (Bool) -> Void) {
        recordingSession.requestRecordPermission { response in
            completionHandler(response)
        }
    }

    var authorizationStatus: AVAudioSession.RecordPermission {
        return recordingSession.recordPermission
    }
}
