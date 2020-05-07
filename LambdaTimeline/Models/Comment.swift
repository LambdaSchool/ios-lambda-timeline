//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    static private let audioURLKey = "audioURL"
    
    let text: String?
    let author: Author
    let timestamp: Date
    let audioURL: URL? 
    
    init(text: String?, audio: URL? author: Author, timestamp: Date = Date()) {
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.audioURL = audioURL
    }
    
    init?(dictionary: [String : Any]) {
        if dictionary[Comment.audioURL] == nil {
        guard let text = dictionary[Comment.textKey] as? String,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
            else { return nil }
        } else {
            guard let text = dictionary[Comment.textKey] as? String,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
            let audioURL1 = dictionary[Comment.audioURLKey] as? URL
            else { return nil }
        }
        
        self.text = text
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.audioURL = audioURL1
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text?,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970,
                Comment.audioURLKey: audioURL?]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
