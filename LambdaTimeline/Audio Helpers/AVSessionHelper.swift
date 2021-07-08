//
//  AVSessionHelper.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

class AVSessionHelper {
    static let shared = AVSessionHelper()
    private init () {}
    
    func setupSessionForAudioRecording() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            guard granted else {
                NSLog("We need microphone access")
                return
            }
            
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.overrideOutputAudioPort(.speaker)
                try session.setActive(true, options: [])
                
            } catch {
                NSLog("Error setting up audio session: \(error)")
            }
        }
    }
}
