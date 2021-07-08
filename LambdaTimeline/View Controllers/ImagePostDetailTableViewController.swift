//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController, CommentPresenterViewControllerDelegate, AudioCommentTableViewCellDelegate, PlayerDelegate {
    
    // MARK: - Properties
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var commentType: CommentType?
    
    private var operations = [URL : Operation]()
    private let audioFetchQueue = OperationQueue()
    private let cache = Cache<URL, Data>()
    private let player = Player()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        updateViews()
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let post = post else { return UITableViewCell() }
        let comment = post.comments[indexPath.row + 1]
        
        switch comment.commentType {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.textLabel?.text = comment.text
            cell.detailTextLabel?.text = comment.author.displayName
            return cell
        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioCommentTableViewCell
            cell.comment = comment
            cell.delegate = self
            loadAudio(for: cell, forItemAt: indexPath)
            return cell
        }
    }
    
    // MARK: - Comments Presenter View Controller Delegate
    func commentPresenter(_ commentPresenter: CommentPresenterViewController, didPublishText comment: String) {
        self.postController.addComment(with: comment, to: self.post!)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func commentPresenter(_ commentPresenter: CommentPresenterViewController, didPublishAudio comment: URL) {
        self.postController.addComment(with: comment, to: self.post!) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Audio Comment Table View Cell Delegate
    func audioCell(_ audioCell: AudioCommentTableViewCell, didPlayPauseAt url: URL) {
        if let audioData = cache.value(for: url) {
            player.playPause(data: audioData)
        }
    }
    
    func isPlaying(url: URL?) -> Bool {
        return false
    }
    
    // MARK: - Player Delegate
    func playerDidChangeState(_ player: Player) {
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CommentPresenterViewController {
            destinationVC.commentDelegate = self
        }
    }
    
    // MARK: - Utility Methods
    private func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    func loadAudio(for audioCommentCell: AudioCommentTableViewCell, forItemAt indexPath: IndexPath) {
        let comment = post.comments[indexPath.row + 1]
        
        guard let audioURL = comment.audioURL else { return }
        
        if let audioData = cache.value(for: audioURL) { return }
        
        let fetchOp = FetchAudioOperation(comment: comment)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData {
                self.cache.cache(value: data, for: audioURL)
            }
        }
        
        let completionOp = BlockOperation {
            self.operations.removeValue(forKey: audioURL)
            print("Loaded audio for \(audioURL.absoluteString)")
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        audioFetchQueue.addOperation(fetchOp)
        audioFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[audioURL] = fetchOp
    }
}
