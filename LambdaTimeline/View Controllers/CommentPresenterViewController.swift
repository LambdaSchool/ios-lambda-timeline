//
//  CommentPresenterViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum CommentType: String {
    case text, audio
}

protocol CommentPresenterViewControllerDelegate: class {
    func commentPresenter(_ commentPresenter: CommentPresenterViewController, didPublishText comment: String)
    func commentPresenter(_ commentPresenter: CommentPresenterViewController, didPublishAudio comment: URL)
}

class CommentPresenterViewController: UITabBarController, TextCommentViewControllerDelegate, AudioCommentViewControllerDelegate {
    
    var textComment: String?
    var audioURL: URL?
    
    weak var commentDelegate: CommentPresenterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(publishComment))

        addDelegatesToChildren()
    }
    
    @objc private func publishComment() {
        if let text = textComment {
            commentDelegate?.commentPresenter(self, didPublishText: text)
        } else if let audioURL = audioURL {
            commentDelegate?.commentPresenter(self, didPublishAudio: audioURL)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Text Comment View Controller Delegate
    func textCommentController(_ textCommentController: TextCommentViewController, didCommit comment: String) {
        textComment = comment
    }
    
    // MARK: - Audio Comment View Controller Delegate
    func audioCommentController(_ audioCommentController: AudioCommentViewController, didCommitAudio comment: URL) {
        audioURL = comment
    }
    
    
    // MARK: - Utility Methods
    private func addDelegatesToChildren() {
        for child in children {
            if let textVC = child as? TextCommentViewController {
                textVC.delegate = self
            }else if let audioVC = child as? AudioCommentViewController {
                audioVC.delegate = self
            }
        }
    }
}
