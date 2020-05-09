//
//  MainTabBarViewController.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol TabBarContained: class {
    var postController: PostController! { get set }
}

class MainTabBarViewController: UITabBarController {

    private let postController = PostController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for child in children {
            if let child = child as? TabBarContained {
                child.postController = postController
            } else if let child = child as? UINavigationController {
                if let rootVC = child.children.first as? TabBarContained {
                    rootVC.postController = postController
                }
            }
        }
        
    }


}
