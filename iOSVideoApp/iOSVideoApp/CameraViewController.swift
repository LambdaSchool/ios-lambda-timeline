//
//  CameraViewController.swift
//  iOSVideoApp
//
//  Created by Ezra Black on 5/6/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    lazy private var captureSession = AVCaptureSession()
        lazy private var fileOutput = AVCaptureMovieFileOutput()
        
        private var player: AVPlayer!
        
        @IBOutlet var recordButton: UIButton!
        @IBOutlet var cameraView: CameraPreviewView!
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Resize camera preview to fill the entire screen
            cameraView.videoPlayerView.videoGravity = .resizeAspectFill
            setUpCaptureSession()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            captureSession.startRunning()
        }
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            captureSession.stopRunning()
        }
        
        private func updateViews() {
            recordButton.isSelected = fileOutput.isRecording
        }
        
        //Live Preview + input/outputs
        
        private func setUpCaptureSession() {
            //Add inputs
            captureSession.beginConfiguration()
            //Camera input
            let camera = bestCamera()
            
            //create input, verify it, add it.
            guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
                captureSession.canAddInput(cameraInput) else {
                    fatalError("Error adding camera to capture session")
            }
            captureSession.addInput(cameraInput)
            
            //Additional configuration/Session Preset.
            if captureSession.canSetSessionPreset(.hd1920x1080) {
                captureSession.sessionPreset = .hd1920x1080
            }
            
            //Microphone input
            
            
            //Add outputs
            guard captureSession.canAddOutput(fileOutput) else {
                fatalError("Cannot save video: Output issue.")
            }
            captureSession.addOutput(fileOutput)
            
            
            captureSession.commitConfiguration()
            cameraView.session = captureSession
            //Start/Stop session
        }
        
        private func bestCamera() -> AVCaptureDevice {
            //checking the camera types.
            if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
                return ultraWideCamera
            }
            if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                return wideAngleCamera
            }
            fatalError("No camera available - are you on a simulator?")
        }
        
        
        @IBAction func recordButtonPressed(_ sender: Any) {
            toggleRecord()
        }
        
        private func toggleRecord() {
            if fileOutput.isRecording {
                fileOutput.stopRecording()
            } else {
                fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
            }
        }
        
        /// Creates a new file URL in the documents directory
        private func newRecordingURL() -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            
            let name = formatter.string(from: Date())
            let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
            return fileURL
        }
        
        private func playMovie(url: URL) {
            player = AVPlayer(url: url)
            let playerView = VideoPlayerView()
            //this should be in viewdidload so it is only added once and add it to the sub view only once (see FIXME below)
            playerView.player = player
            // top left corner (Fullscreen, you'd need a close button)
            var topRect = view.bounds
            topRect.size.height = topRect.size.height / 4
            topRect.size.width = topRect.size.width / 4 // create a constant for the "magic number"
            topRect.origin.y = view.layoutMargins.top
            playerView.frame = topRect
            view.addSubview(playerView) // FIXME: Don't add every time we play
            player.play()
        }
    }

    extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if let error = error {
                print("error saving video: \(error)")
            } else {
                //show movie
                playMovie(url: outputFileURL)
            }
            updateViews()
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
            print("Started Recording \(fileURL)")
            updateViews()
        }
}
