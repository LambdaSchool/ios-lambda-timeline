//
//  UIAlertController+informationAlert.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func informationalAlertController(title: String? = "Error", message: String?, dismissActionCompletion: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: dismissActionCompletion)
        
        alertController.addAction(dismissAction)
        
        return alertController
    }
}
