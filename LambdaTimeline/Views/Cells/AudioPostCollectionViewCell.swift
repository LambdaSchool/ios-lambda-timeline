//
//  AudioPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class AudioPostCollectionViewCell: PostCollectionViewCell {
    @IBOutlet private(set) var audioPlayerControl: AudioPlayerControl!

    override func prepareForReuse() {
        super.prepareForReuse()
        audioPlayerControl.loadAudio(from: nil)
    }

    func setAudioURL(_ url: URL?) {
        audioPlayerControl.loadAudio(from: url)
    }
}
