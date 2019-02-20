//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController, RecorderDelegate, PlayerDelegate {

    private let recorder = Recorder()
    private let player = Player()
    
    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVSessionHelper.shared.setupSessionForAudioRecording()

        updateViews()
        recorder.delegate = self
        player.delegate = self
    }

    @IBAction func toggleRecord(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    @IBAction func playPause(_ sender: Any) {
        player.playPause(file: recorder.currentFile)
    }
    
    // MARK: - Player Delegate
    func playerDidChangeState(_ player: Player) {
        updateViews()
    }
    
    // MARK: - Recorder Delegate
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    // MARK: - Utility Methods
    private func updateViews() {
        recordButton.isEnabled = !player.isPlaying
        listenButton.isEnabled = recorder.currentFile != nil && !recorder.isRecording
        
        let recordTitle = recorder.isRecording ? "Stop" : "Record"
        recordButton.setTitle(recordTitle, for: .normal)
        
        let listenTitle = player.isPlaying ? "Pause" : "Listen"
        listenButton.setTitle(listenTitle, for: .normal)
        
        updateTimeLabel()
    }
    
    private func updateTimeLabel() {
        if recorder.isRecording {
            timeLabel.text = timeFormatter.string(from: recorder.recordingLength)
        } else if player.isPlaying {
            timeLabel.text = timeFormatter.string(from: player.elapsedTime)
        } else {
            timeLabel.text = timeFormatter.string(from: recorder.recordingLength)
        }
    }
    
}
