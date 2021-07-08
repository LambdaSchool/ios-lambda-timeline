//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var viewPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return viewPreviewLayer.session }
        set { viewPreviewLayer.session = newValue }
    }

}
