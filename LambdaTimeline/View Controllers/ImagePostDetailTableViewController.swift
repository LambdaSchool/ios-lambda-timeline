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
    private var currentlyPlaying: (indexPath: IndexPath, cell: AudioCommentTableViewCell)?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AVSessionHelper.shared.setupSessionForAudioPlayback()
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
            cell.delegate = self
            cell.comment = comment
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
        if let audioData = cache.value(for: url), let indexPath = tableView.indexPath(for: audioCell) {
            player.playPause(data: audioData)
            currentlyPlaying = (indexPath, audioCell)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func isPlaying(url: URL?) -> Bool {
        if let url = url, let data = cache.value(for: url), data == player.currentData {
            return player.isPlaying
        }
        return false
    }
    
    func isDownloaded(url: URL?) -> Bool {
        if let url = url, cache.value(for: url) != nil { return true }
        return false
    }
    
    // MARK: - Player Delegate
    func playerDidChangeState(_ player: Player) {
        if let currentlyPlaying = currentlyPlaying,  let indexPath = tableView.indexPath(for: currentlyPlaying.cell), indexPath == currentlyPlaying.indexPath {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CommentPresenterViewController {
            destinationVC.commentDelegate = self
        } else if let destinationVC = segue.destination as? PostContentViewController {
            destinationVC.post = post
            destinationVC.imageData = imageData
        }
    }
    
    // MARK: - Utility Methods
    private func updateViews() {        
        title = post?.title
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    func loadAudio(for audioCommentCell: AudioCommentTableViewCell, forItemAt indexPath: IndexPath) {
        let comment = post.comments[indexPath.row + 1]
        
        guard let audioURL = comment.audioURL else { return }
        
        if cache.value(for: audioURL) != nil { return }
        
        let fetchOp = FetchAudioOperation(comment: comment)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData {
                self.cache.cache(value: data, for: audioURL)
            }
        }
        
        let completionOp = BlockOperation {
            self.operations.removeValue(forKey: audioURL)
            
            if let currentIndexPath = self.tableView.indexPath(for: audioCommentCell),
                currentIndexPath != indexPath { return }
            
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        cacheOp.addDependency(fetchOp)
        
        completionOp.addDependency(cacheOp)
        
        audioFetchQueue.addOperation(fetchOp)
        audioFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[audioURL] = fetchOp
    }
}
