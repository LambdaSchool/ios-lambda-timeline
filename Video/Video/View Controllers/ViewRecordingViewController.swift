//
//  ViewRecordingViewController.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import AVFoundation

extension UIViewController {
    func hideKeyboardWhenViewTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewRecordingViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var videoPlayerView: VideoPlayerView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    private var player: AVPlayer!
    
    var recordingURL: URL?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenViewTapped()
        updateViews()
        playMovie(url: recordingURL)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }
    
    // MARK: - Private Methods
    private func updateViews() {
        videoPlayerView.videoPlayerLayer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.cornerRadius = 8
        cancelButton.layer.cornerRadius = 8
        saveButton.layer.cornerRadius = 8
        nameTextField.layer.cornerRadius = 8
    }
    
    private func playMovie(url: URL?) {
        guard let url = url else { return }
        print("playing \(url)")
        player = AVPlayer(url: url)
        videoPlayerView.player = player
        player.play()
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        guard let url = recordingURL else { return }

        do {
            try FileManager.default.removeItem(at: url)
            dismiss(animated: true, completion: nil)
        } catch {
            print("Could not delete file: \(error)")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let videoName = nameTextField.text, !videoName.isEmpty else { return }
        guard let url = recordingURL else { return }
        let video = Video(recordingURL: url, name: videoName)
        videoController.videos.append(video)
        dismiss(animated: true, completion: nil)
    }
}
