//
//  PostContentViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class PostContentViewController: UIViewController {
    
    var post: Post!
    var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()

        switch post.mediaType {
        case .image:
            setupImageView()
        case .video:
            // TODO: Actually show video content.
            break
        }
        
    }
    
    private func setupImageView() {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.constrainToFill(view)
        
        if let data = imageData {
            imageView.image = UIImage(data: data)
        }
        
    }
    
}
