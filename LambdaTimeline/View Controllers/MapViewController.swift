//
//  MapViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, TabBarContained {

    @IBOutlet weak var mapView: MKMapView!
    
    var postController: PostController!
    
    private var posts: Set<Post> = [] {
        didSet {
            
            let addedPosts = posts.subtracting(oldValue)
            let removePosts = oldValue.subtracting(posts)
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(Array(removePosts))
                self.mapView.addAnnotations(Array(addedPosts))
            }
            
        }
    }
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationHelper.shared.requestAccess(completion: { granted in
            DispatchQueue.main.async {
                if granted {
                    let userTrackingButton = MKUserTrackingButton(mapView: self.mapView)
                    userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
                    self.mapView.addSubview(userTrackingButton)
                    
                    userTrackingButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
                    userTrackingButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
                }
            }
        })
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PostAnnotationView")
        
        fetchPosts()
    }
    
    // MARK: - MK Map View Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Post else { return nil }
        
        let postView = mapView.dequeueReusableAnnotationView(withIdentifier: "PostAnnotationView", for: annotation) as! MKMarkerAnnotationView
        
        // TODO: Add a glyph for the annotations
//        postView.glyphImage = UIImage(named: "")!
//        postView.glyphTintColor = .white
        
        return postView
    }
    
    // MARK: - Utility Methods
    private func fetchPosts() {
        posts = postController.postsWithAnnotations()
    }
}
