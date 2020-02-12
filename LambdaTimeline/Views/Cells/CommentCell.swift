//
//  CommentCell.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var audioPlayerStackView: UIStackView!
    
    var manager = AudioManager()
    static let reuseID = "CommentCell"
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    var comment: Comment? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        timeElapsedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeElapsedLabel.font.pointSize, weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize, weight: .regular)
        
        guard let comment = comment else { return }
        if let audio = comment.audio {
            guard let audioURL = URL(string: audio) else { return }
            manager.loadAudio(with: audioURL)
            manager.delegate = self
            updateViews(withComment: true)
        } else {
            timeElapsedLabel.removeFromSuperview()
            timeRemainingLabel.removeFromSuperview()
            valueSlider.removeFromSuperview()
            audioPlayerStackView.removeFromSuperview()
        }
        
        titleLabel.text = comment.text
        authorLabel.text = comment.author.displayName
    }
    
    private func updateViews(withComment: Bool) {
        if withComment {
            let elapsedTime = manager.audioPlayer?.currentTime ?? 0
            timeElapsedLabel.text = timeIntervalFormatter.string(from: elapsedTime)
            
            valueSlider.minimumValue = 0
            valueSlider.maximumValue = Float(manager.audioPlayer?.duration ?? 0)
            valueSlider.value = Float(elapsedTime)
            
            let timeRemaining = (manager.audioPlayer?.duration ?? 0) - elapsedTime
            timeRemainingLabel.text = "-\(timeIntervalFormatter.string(from: timeRemaining) ?? "")"
        }
    }
}

extension CommentCell: AudioManagerDelegate {
    func didPlay() {
        updateViews(withComment: true)
    }
    
    func didPause() {
        updateViews(withComment: true)
    }
    
    func didFinishPlaying() {
        updateViews(withComment: true)
    }
    
    func didUpdate() {
        updateViews(withComment: true)
    }
    
    func isRecording() {
        return
    }
    
    func doneRecording(with url: URL) {
        return
    }
}
