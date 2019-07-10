//
//  Player.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

class Player: NSObject { //has to be of nsobject so that we can conform to a protocol
    
    //need the actual thing/object to access its functionality
    private var audioPlayer: AVAudioPlayer? //So that we can create it at a later time
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    //MARK: Functionality of the player
    
    //playing
    func play(){
        audioPlayer?.play()
    }
 
    //pausing
    func pause(){
        audioPlayer?.pause()
    }
    
    
}
