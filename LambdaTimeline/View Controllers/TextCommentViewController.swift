//
//  TextCommentViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol TextCommentViewControllerDelegate: class {
    func textCommentController(_ textCommentController: TextCommentViewController, didCommit comment: String)
}

class TextCommentViewController: UIViewController, UITextViewDelegate {
    
    weak var delegate: TextCommentViewControllerDelegate?
    
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
    }
    
    // MARK: - UI Text View Delegate
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let comment = textView.text else { return }
        delegate?.textCommentController(self, didCommit: comment)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
