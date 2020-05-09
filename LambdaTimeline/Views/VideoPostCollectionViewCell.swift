//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    private var videoURL: URL?
    private var player: AVPlayer?
    private var isPlaying: Bool = false
    
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: GradientView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        labelBackgroundView.setupGradient(startColor: .darkerBlack, endColor: .lighterBlack)
    }
    
    override func prepareForReuse() {
        isPlaying = false
        player = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    // TODO: Handle replaying of a video more gracefully
    func playPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    private func updateViews() {
        guard let post = post else { return }
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
        
        if player == nil {
            let item = AVPlayerItem(url: post.mediaURL)
            player = AVPlayer(playerItem: item)
            videoPlayerView.player = player
        }
    }
    
}
