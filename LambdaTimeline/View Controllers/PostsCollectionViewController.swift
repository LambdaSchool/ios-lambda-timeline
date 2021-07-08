//
//  PostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    private let postController = PostController()
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postController.observePosts { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - UI Actions
    @IBAction func addPost(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Post", message: "Which kind of post do you want to create?", preferredStyle: .actionSheet)
        
        let imagePostAction = UIAlertAction(title: "Image", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddImagePost", sender: nil)
        }
        
        let videoPostAction = UIAlertAction(title: "Video", style: .default, handler: videoPostAlertActionHandler)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(imagePostAction)
        alert.addAction(videoPostAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UI Collection View Data Source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
            
        case .image:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell", for: indexPath) as? ImagePostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.post = post
            
            loadImage(for: cell, forItemAt: indexPath)
            
            return cell
            
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPostCell", for: indexPath) as! VideoPostCollectionViewCell
            
            cell.post = post
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        
        let post = postController.posts[indexPath.row]
        
        switch post.mediaType {
            
        case .image:
            
            guard let ratio = post.ratio else { return size }
            
            size.height = size.width * ratio
            
        case .video:
            if let ratio = post.ratio { size.height = size.width * ratio }
        }
        
        return size
    }
    
    // MARK: - UI Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if let cell = cell as? ImagePostCollectionViewCell,
            cell.imageView.image != nil {
        }
        self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? VideoPostCollectionViewCell {
            cell.playPause()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let cell = cell as? VideoPostCollectionViewCell {
            cell.pause()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        guard let postID = postController.posts[indexPath.row].id else { return }
        operations[postID]?.cancel()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddImagePost" {
            let destinationVC = segue.destination as? ImagePostViewController
            destinationVC?.postController = postController
            
        } else if segue.identifier == "AddVideoPostSegue" {
            let destinactionVC = segue.destination as! VideoPostViewController
            destinactionVC.postController = postController
        } else if segue.identifier == "ViewImagePost" {
            
            let destinationVC = segue.destination as? ImagePostDetailTableViewController
            
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                let postID = postController.posts[indexPath.row].id else { return }
            
            destinationVC?.postController = postController
            destinationVC?.post = postController.posts[indexPath.row]
            destinationVC?.imageData = cache.value(for: postID)
        }
    }
    
    // MARK - Utility Methods
    private func loadImage(for imagePostCell: ImagePostCollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = postController.posts[indexPath.row]
        
        guard let postID = post.id else { return }
        
        if let mediaData = cache.value(for: postID),
            let image = UIImage(data: mediaData) {
            imagePostCell.setImage(image)
            self.collectionView.reloadItems(at: [indexPath])
            return
        }
        
        let fetchOp = FetchMediaOperation(post: post, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.cache.cache(value: data, for: postID)
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: postID) }
            
            if let currentIndexPath = self.collectionView?.indexPath(for: imagePostCell),
                currentIndexPath != indexPath {
                return
            }
            
            if let data = fetchOp.mediaData {
                imagePostCell.setImage(UIImage(data: data))
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[postID] = fetchOp
    }
    
    private func videoPostAlertActionHandler(alertAction: UIAlertAction) {
        AVCaptureDeviceHelper.shared.checkAuthorizationStatus { (alertController) in
            DispatchQueue.main.async {
                if let alertController = alertController {
                    self.present(alertController, animated: true)
                } else {
                    self.performSegue(withIdentifier: "AddVideoPostSegue", sender: self)
                }
            }
        }
    }
}
