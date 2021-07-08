//
//  GradientView.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    func setupGradient(startColor: UIColor = .white, endColor: UIColor = .white, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [startColor.cgColor, endColor.cgColor]
        layer.startPoint = startPoint
        layer.endPoint = endPoint
    }
}
