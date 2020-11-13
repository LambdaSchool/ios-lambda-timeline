//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit

enum MediaType {
    case image(UIImage)
    case video(URL)
}

class Post: Equatable {
    
    let mediaType: MediaType
    let author: String
    let timestamp: Date
    var comments: [Comment]
    var ratio: CGFloat?
    var geotag: CLLocationCoordinate2D?
    var id: String?
    
    var title: String? {
        return comments.first?.text
    }
    
    init(title: String, mediaType: MediaType, ratio: CGFloat? = nil, geotag: CLLocationCoordinate2D? = nil, author: String, timestamp: Date = Date()) {
        self.mediaType = mediaType
        self.ratio = ratio
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
        self.geotag = geotag
        self.id = UUID().uuidString
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}
