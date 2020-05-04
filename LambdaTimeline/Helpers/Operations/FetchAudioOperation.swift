//
//  FetchAudioOperation.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

//import Foundation
//
//class FetchAudioOperation: ConcurrentOperation {
//    
//    init(post: Post, postController: PostController, session: URLSession = URLSession.shared) {
//        self.post = post
//        self.postController = postController
//        self.session = session
//        super.init()
//    }
//    
//    override func start() {
//        state = .isExecuting
//        
////        let url = post.audioURL
//        
//        let task = session.dataTask(with: url!) { (data, response, error) in
//            defer { self.state = .isFinished }
//            if self.isCancelled { return }
//            if let error = error {
//                NSLog("Error fetching data for \(self.post): \(error)")
//                return
//            }
//            
//            guard let data = data else {
//                NSLog("No data returned from fetch media operation data task.")
//                return
//            }
//            
//            self.audioData = data
//        }
//        task.resume()
//        dataTask = task
//    }
//    
//    override func cancel() {
//        dataTask?.cancel()
//        super.cancel()
//    }
//    
//    // MARK: Properties
//    
//    let post: Post
//    let postController: PostController
//    var audioData: Data?
//    
//    private let session: URLSession
//    
//    private var dataTask: URLSessionDataTask?
//    
//}
