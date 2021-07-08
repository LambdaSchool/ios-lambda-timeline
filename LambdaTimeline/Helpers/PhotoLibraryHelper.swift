//
//  PhotoLibraryHelper.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import Photos

class PhotoLibraryHelper {
    static let shared = PhotoLibraryHelper()
    private init() {}
    
    func checkAuthorizationStatus(completion: @escaping (UIAlertController?) -> Void) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            completion(nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    completion(self.informationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it."))
                    return
                }
                completion(nil)
            }
        case .denied:
            completion(informationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it."))
        case .restricted:
            completion(informationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access."))
        }
    }
    
    private func informationalAlertController(title: String?, message: String?, dismissActionCompletion: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: dismissActionCompletion)
        
        alertController.addAction(dismissAction)
        
        return alertController
    }
}
