//
//  ViewController.swift
//  iOSVideoApp
//
//  Created by Ezra Black on 5/6/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissionAndShowCamera()
    }
    
    //capture device lets us wrap up our inputs/outputs
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined: // first time we've requested access
            requestPermission()
        case .restricted: // parental controls prevent user from camera/mic
            fatalError("Tell user they need to request permission from parent")
        case .denied:
            fatalError("enable permissions in system preferences!")
        case .authorized:
            showCamera()
        default:
            fatalError("Handle new case for authorization due to deprication")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            guard granted else {
                fatalError("enable permissions in system preferences!")
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
}

