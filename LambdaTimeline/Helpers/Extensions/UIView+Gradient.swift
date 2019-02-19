//
//  UIView+Gradient.swift
//  Lambda Timeline
//
//  Created by Dillon McElhinney on 1/3/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

extension UIView {
    func addGradient(startColor: UIColor, endColor: UIColor, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = self.layer.frame
        
        self.layer.addSublayer(gradient)
        self.layer.backgroundColor = endColor.cgColor
    }
}
