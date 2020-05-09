//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreLocation
import MapKit

enum MediaType: String {
    case image
    case video
}

class Post: NSObject {
    
    init(title: String, mediaType: MediaType, mediaURL: URL, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date(), geotag: CLLocationCoordinate2D? = nil) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = mediaType
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
        self.geotag = geotag
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]] else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
        self.geotag = CLLocationCoordinate2D(dictionary: dictionary[Post.geotagKey] as? [String : Any] ?? [:])
    }
    
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970]
        
        if let ratio = self.ratio {
            dict[Post.ratioKey] = ratio
        }
        
        if let geotag = geotag {
            dict[Post.geotagKey] = geotag.dictionaryRepresentation
        }
        
        
        return dict
    }
    
    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var ratio: CGFloat?
    let geotag: CLLocationCoordinate2D?
    
    var title: String? {
        return comments.first?.text
    }
    
    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    static private let geotagKey = "geotag"
}

extension Post: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return geotag ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    var subtitle: String? {
        return author.displayName
    }
    
    
}


extension CLLocationCoordinate2D {
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    
    var dictionaryRepresentation: [String: Any] {
        let dict = [
            CLLocationCoordinate2D.latitudeKey: latitude,
            CLLocationCoordinate2D.longitudeKey: longitude
        ]
        
        return dict
    }
    
    init?(dictionary: [String: Any]) {
        guard let latitude = dictionary[CLLocationCoordinate2D.latitudeKey] as? CLLocationDegrees,
            let longitude = dictionary[CLLocationCoordinate2D.longitudeKey] as? CLLocationDegrees else { return nil }
        
        self.init(latitude: latitude, longitude: longitude)
    }
}
