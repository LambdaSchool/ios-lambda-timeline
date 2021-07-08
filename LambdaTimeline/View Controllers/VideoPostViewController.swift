//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoPostViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVPlayerViewControllerDelegate {
    
    // MARK: - Properties
    var postController: PostController!
    
    
    private let captureSession = AVCaptureSession()
    private let fileOutput = AVCaptureMovieFileOutput()
    private var isOnBackCamera = true
    private var videoTitle: String? {
        didSet { postVideo() }
    }
    private var currentURL: URL? {
        didSet { updatePostButton() }
    }
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSessionInputs()
        let hasOutput = setupSessionOutputs()
        setupRecordButton(!hasOutput)
        updatePostButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - UI Actions
    @IBAction func toggleRecording(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    @IBAction func postVideo(_ sender: Any) {
        presentTitleAlert()
    }
    
    @IBAction func swipeToChangeCameras(_ sender: Any) {
        rotateCamera()
    }
    
    // MARK: - AV Capture File Output Recording Delegate
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        updateViews()
        currentURL = outputFileURL
        
        let player = AVPlayer(url: outputFileURL)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.showsPlaybackControls = true
        playerViewController.player = player
        present(playerViewController, animated: true)
        
    }
    
    // MARK: - Utility Methods
    private func backCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            return device
        }
        return nil
    }
    
    private func frontCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    }
    
    private func setupSessionInputs() {
        let camera = backCamera()
        guard let backCamera = camera, let cameraInput = try? AVCaptureDeviceInput(device: backCamera) else { fatalError("Can't create input from camera.") }
        guard captureSession.canAddInput(cameraInput) else { fatalError("Session can't add that input.") }
        
        captureSession.beginConfiguration()
        captureSession.addInput(cameraInput)
        
        if let microphone = AVCaptureDevice.default(for: .audio),
            let microphoneInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(microphoneInput) {
            captureSession.addInput(microphoneInput)
        }
        
        if captureSession.canSetSessionPreset(.medium) {
            captureSession.sessionPreset = .medium
        }
        captureSession.commitConfiguration()
        
        cameraView.viewPreviewLayer.videoGravity = .resizeAspectFill
        cameraView.session = captureSession
    }
    
    private func setupSessionOutputs() -> Bool {
        guard captureSession.canAddOutput(fileOutput) else { return false }
        captureSession.addOutput(fileOutput)
        return true
    }
    
    private func rotateCamera() {
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        captureSession.beginConfiguration()

        if let microphone = AVCaptureDevice.default(for: .audio),
            let microphoneInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(microphoneInput) {
            captureSession.addInput(microphoneInput)
        }
        
        if isOnBackCamera {
            if let camera = frontCamera(), let cameraInput = try? AVCaptureDeviceInput(device: camera), captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                captureSession.commitConfiguration()
                isOnBackCamera = false
                return
            }
        }
        guard let camera = backCamera(), let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Can't create input from camera.") }
        guard captureSession.canAddInput(cameraInput) else { fatalError("Session can't add that input.") }
        
        captureSession.addInput(cameraInput)
        captureSession.commitConfiguration()
        isOnBackCamera = true
        
    }
    
    // MARK: Persistence Utilities
    private func newRecordingURL() -> URL {
        let documentDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let fileURL = documentDir.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func postVideo() {
        if let title = videoTitle, !title.isEmpty, let url = currentURL, let data = try? Data(contentsOf: url) {
            postButton.isEnabled = false
            recordButton.isEnabled = false
            postController.createPost(with: title, ofType: .video, mediaData: data, ratio: 4/3) { success in
                self.navigationController?.popViewController(animated: true)
                // TODO: Handle unsuccessful posting
            }
        } else {
            let errorAlert = UIAlertController.informationalAlertController(message: "You need a title and a video to make a post!")
            present(errorAlert, animated: true)
            recordButton.isEnabled = true
            updatePostButton()
        }
    }
    
    // MARK: UI Utilities
    private func setupRecordButton(_ shouldShow: Bool) {
        recordButton.backgroundColor = .white
        recordButton.layer.masksToBounds = true
        recordButton.layer.cornerRadius = 8
        recordButton.layer.borderColor = UIColor.gray.cgColor
        recordButton.layer.borderWidth = 0.5
        recordButton.isHidden = shouldShow
    }
    
    private func updateViews() {
        DispatchQueue.main.async {
            let isRecording = self.fileOutput.isRecording
            let recordTitle = isRecording ? "Stop" : "Record"
            self.recordButton.setTitle(recordTitle, for: .normal)
        }
    }
    
    private func updatePostButton() {
        postButton.isEnabled = currentURL != nil
    }
    
    private func presentTitleAlert() {
        let alertController = UIAlertController(title: "Give it a title", message: nil, preferredStyle: .alert)
        
        var titleTextField: UITextField!
        alertController.addTextField { (textField) in
            textField.placeholder = "Your title"
            titleTextField = textField
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            self.videoTitle = titleTextField.text
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
}
