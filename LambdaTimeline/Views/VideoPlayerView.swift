//
//  VideoPlayerView.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var viewPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    var player: AVPlayer? {
        get { return viewPlayerLayer.player }
        set { viewPlayerLayer.player = newValue }
    }
}
