//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol AudioCommentTableViewCellDelegate: class {
    
    func audioCell(_ audioCell: AudioCommentTableViewCell, didPlayPauseAt url: URL)
    func isPlaying(url: URL?) -> Bool
}

class AudioCommentTableViewCell: UITableViewCell {

    weak var delegate: AudioCommentTableViewCellDelegate?
    
    var isPlaying: Bool {
        return delegate?.isPlaying(url: comment?.audioURL) ?? false
    }
    
    var comment: Comment? {
        didSet { updateViews() }
    }
    
    @IBOutlet weak var commenterLabel: UILabel!
    @IBOutlet weak var listenButton: UIButton!
    
    @IBAction func playPause(_ sender: Any) {
        guard let audioURL = comment?.audioURL else { return }
        delegate?.audioCell(self, didPlayPauseAt: audioURL)
    }
    
    private func updateViews() {
        guard let comment = comment else { return }
        commenterLabel.text = comment.author.displayName
        
        let listenTitle = isPlaying ? "Pause" : "Listen"
        listenButton.setTitle(listenTitle, for: .normal)
    }
}
