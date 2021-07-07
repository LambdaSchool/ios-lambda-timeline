//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Sergey Osipyan on 2/20/19.
//  Copyright © 2019 Sergey Osipyan. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var post: Post?
    let postController = PostController()
    var vidoeRecordedURL: URL?
    
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBAction func saveButton(_ sender: Any) {
    
        guard let videoURL = vidoeRecordedURL else { return }
        
        let data = try? Data(contentsOf: videoURL)
        
        
        
        
        self.postController.store(mediaData: data! as Data, mediaType: .video) { (url) in

            guard let url = url else { return }
            self.postController.addComment(with: "Video post", video: url, to: self.post!)
        }
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    
    }
    
        
    
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    @IBAction func recordButton(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    private let fileOutput = AVCaptureMovieFileOutput()
    private let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = bestCamera()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Cant't create input")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("this session can't handle this kind o input.")
        }
        captureSession.addInput(cameraInput)
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record to file")
        }
        
        captureSession.addOutput(fileOutput)
        
        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
        captureSession.sessionPreset = .hd4K3840x2160 // try
        } else {
            captureSession.sessionPreset = .high
        }
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        captureSession.startRunning()
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         captureSession.startRunning()
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus{
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted == false {
                    fatalError("Please don't do this in an actual app")
                }
                DispatchQueue.main.async {
                     print("Auth")
                }
            }
        case .restricted:
            fatalError("Please have better scenario handling than this in real life")
        case .denied:
            fatalError("Please have better scenario handling than this in real life")
        case .authorized:
            print("Auth")

        }
        
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
        self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
        self.updateViews()
        }
        
        vidoeRecordedURL = outputFileURL
        
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else { return }
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
//            }, completionHandler: { (success, error) in
//                if let error = error {
//                    NSLog("error saving video: \(error)")
//                } else {
//                    NSLog("saving video succeeded")
//                }
//            })
//        }
    }
    
    
    private func bestCamera() -> AVCaptureDevice {
        
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
        return device
        }
        if let device = AVCaptureDevice.default( .builtInWideAngleCamera, for: .video, position: .back) {
        return device
            
    }
    fatalError("no camera on device")
}
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documents = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        
        let name = f.string(from: Date())
        return documents.appendingPathComponent(name).appendingPathExtension("mov")
    }
    
    private func updateViews() {
        
        let isRecording = fileOutput.isRecording
        record.setTitle(isRecording ? "Stop" : "Record", for: .normal)
    }
//    private func showCamera() {
//        performSegue(withIdentifier: "showCamera", sender: self)
//    }

}

