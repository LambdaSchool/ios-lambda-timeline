//
//  FetchAudioOperation.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchAudioOperation: ConcurrentOperation {
    
    // MARK: Properties
    let comment: Comment
    var audioData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
    
    // MARK: - Initializers
    init(comment: Comment, session: URLSession = URLSession.shared) {
        self.comment = comment
        self.session = session
        super.init()
    }
    
    // MARK: - Operation Methods
    override func start() {
        state = .isExecuting
        
        guard let url = comment.audioURL else { self.state = .isFinished; return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.comment): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch media operation data task.")
                return
            }
            
            self.audioData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    

    
}
