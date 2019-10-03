//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//
//swiftlint:disable multiple_closures_with_trailing_closure

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PostController {
	var posts: [Post] = []
	let currentUser = Auth.auth().currentUser
	let postsRef = Database.database().reference().child("LambdaTimeline").child("posts")
	let storageRef = Storage.storage().reference().child("LambdaTimeline")

	func createPost(with title: String,
					ofType mediaType: MediaType,
					mediaData: Data,
					ratio: CGFloat? = nil,
					latitude: Double?,
					longitude: Double?,
					completion: @escaping (Bool) -> Void = { _ in }) {
		guard let currentUser = Auth.auth().currentUser,
			let author = Author(user: currentUser) else { return }
		
		store(mediaData: mediaData, at: storageRef.child(mediaType.rawValue)) { mediaURL in
			guard let mediaURL = mediaURL else { completion(false); return }
			
			let imagePost = Post(title: title, mediaURL: mediaURL, ratio: ratio,
								 author: author, mediaType: mediaType, latitude: latitude, longitude: longitude)
			self.postsRef.childByAutoId().setValue(imagePost.dictionaryRepresentation) { error, _ in
				if let error = error {
					NSLog("Error posting image post: \(error)")
					completion(false)
				}
				completion(true)
			}
		}
	}
	
	func addComment(with text: String, to post: inout Post, completion: @escaping () -> Void) {
		guard let currentUser = Auth.auth().currentUser,
			let author = Author(user: currentUser) else {
				completion()
				return
		}
		
		let comment = Comment(text: text, author: author)
		post.comments.append(comment)
		
		savePostToFirebase(post) { _ in
			completion()
		}
	}

	func addComment(with audio: Data, to post: Post, completion: @escaping () -> Void) {
		guard let currentUser = Auth.auth().currentUser,
			let author = Author(user: currentUser) else {
				completion()
				return
		}

		store(mediaData: audio, at: storageRef.child("audio")) { url in
			guard let audioURL = url else {
				completion()
				return
			}
			let comment = Comment(audioURL: audioURL, author: author)
			post.comments.append(comment)

			self.savePostToFirebase(post) { _ in
				completion()
			}
		}
	}

	func observePosts(completion: @escaping (Error?) -> Void) {
		postsRef.observe(.value, with: { snapshot in
			guard let postDictionaries = snapshot.value as? [String: [String: Any]] else { return }
			var posts: [Post] = []
			
			for (key, value) in postDictionaries {
				guard let post = Post(dictionary: value, id: key) else { continue }
				posts.append(post)
			}
			self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
			
			completion(nil)
		}) { error in
			NSLog("Error fetching posts: \(error)")
		}
	}
	
	func savePostToFirebase(_ post: Post, completion: @escaping (Error?) -> Void = { _ in }) {
		guard let postID = post.id else {
			let error = NSError(domain: "no post id", code: -1, userInfo: nil)
			completion(error)
			return
		}
		
		let ref = postsRef.child(postID)
		ref.setValue(post.dictionaryRepresentation) { error, _ in
			completion(error)
		}
	}

	private func store(mediaData: Data, at location: StorageReference, completion: @escaping (URL?) -> Void) {
		let mediaID = UUID().uuidString
		let mediaRef = location.child(mediaID)
		
		let uploadTask = mediaRef.putData(mediaData, metadata: nil) { metadata, error in
			if let error = error {
				NSLog("Error storing media data: \(error)")
				completion(nil)
				return
			}
			
			if metadata == nil {
				NSLog("No metadata returned from upload task.")
				completion(nil)
				return
			}
			
			mediaRef.downloadURL(completion: { url, error in
				if let error = error {
					NSLog("Error getting download url of media: \(error)")
				}
				
				guard let url = url else {
					NSLog("Download url is nil. Unable to create a Media object")
					
					completion(nil)
					return
				}
				completion(url)
			})
		}
		uploadTask.resume()
	}
}
