//
//  FileManager+Extensions.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/10/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import Foundation

extension FileManager {
    func documentURL(_ docName: String) -> URL {
        var documentsDirectoryURL: URL

        do {
            documentsDirectoryURL = try url(for: .documentDirectory,
                in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            documentsDirectoryURL = URL(fileURLWithPath: "")
        }

        return documentsDirectoryURL.appendingPathComponent(docName)
    }

    func createSleepRecordingsFolderIfNeeded() {
        guard !fileExists(atPath: sleepRecordingFolderURL().absoluteString) else {
            return
        }

        try? createDirectory(at: sleepRecordingFolderURL(), withIntermediateDirectories: false, attributes: nil)
    }

    func generateSleepRecordingURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-hh-mm"

        return sleepRecordingFolderURL().appendingPathComponent("recording_\(dateFormatter.string(from: Date())).m4a")
    }

    func sleepRecordingFolderURL() -> URL {
        return documentURL("sleep_recordings")
    }

    func temporaryDocumentURL(_ docName: String) -> URL {
        return temporaryDirectory.appendingPathComponent(docName)
    }
}
