//
//  UIImage+getCIImage.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

extension UIImage {
    func getCIImage() -> CIImage? {
        if let ciImage = self.ciImage {
            return ciImage
        } else if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
