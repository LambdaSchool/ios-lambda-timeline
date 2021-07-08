//
//  FilterSlider.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class FilterSlider {
    let attributeName: String
    let displayName: String
    let minimumValue: Float
    let maximumValue: Float
    let defaultValue: Float
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.value = defaultValue
        return slider
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = displayName
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    lazy var view: UIView = {
        let stack = UIStackView(arrangedSubviews: [label, slider])
        stack.axis = .horizontal
        stack.spacing = UIStackView.spacingUseSystem
        return stack
    }()
    
    var value: Float {
        return slider.value
    }
    
    init?(name: String, attributes: Any) {
        guard let attributes = attributes as? Dictionary<String, Any> else { return nil }
        
        guard let valueClassName = attributes[kCIAttributeClass] as? String else { return nil }
        guard valueClassName == "NSNumber" else { return nil }
        
        guard let minValue = attributes[kCIAttributeSliderMin] as? Double else { return nil }
        guard let maxValue = attributes[kCIAttributeSliderMax] as? Double else { return nil }
        
        let identityValue = attributes[kCIAttributeIdentity] as? Float
        let defaultValue = attributes[kCIAttributeDefault] as? Float
        
        self.attributeName = name
        self.displayName = attributes[kCIAttributeDisplayName] as? String ?? name
        self.minimumValue = Float(minValue)
        self.maximumValue = Float(maxValue)
        self.defaultValue = defaultValue ?? identityValue ?? Float(minValue)
    }
}
