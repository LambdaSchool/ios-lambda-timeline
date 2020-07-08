//
//  CircleSplashControl.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class CircleSplashControl: UIView {
    //MARK: - Properties -
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var centerXTextField: UITextField!
    @IBOutlet weak var centerYTextField: UITextField!
    
    
    private var filters = Filters()
    var image: UIImage?
    var delegate: FilteredImageDelegate?
    
    
    //MARK: - Life Cycles -
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        //not sure if this or the below is right will test both
        //        Bundle.main.loadNibNamed("MotionBlurControl", owner: self, options: nil)
        //        addSubview(contentView)
        //        contentView.frame = self.bounds
        //        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let name = String(describing: type(of: self))
        let nib = UINib(nibName: name, bundle: .main)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    
    //MARK: - Actions -
    @IBAction func filter(_ sender: Any) {
        guard let image = image else { return }
        
        let xText = centerXTextField.text ?? "150"
        let yText = centerYTextField.text ?? "150"
        let xInt = Int(xText) ?? 150
        let yInt = Int(yText) ?? 150
        let xCGFloat = CGFloat(exactly: xInt)!
        let yCGFloat = CGFloat(exactly: yInt)!
        let vector = CIVector(x: xCGFloat, y: yCGFloat)
        
        let filteredImage = filters.circleSplash(for: image,
                                                 at: vector,
                                                 radius: radiusSlider.value)
        delegate?.filteredImage(filteredImage)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.saveCurrentImage()
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        radiusSlider.minimumValue = 0
        radiusSlider.maximumValue = 1000
        radiusSlider.setValue(150, animated: false)
        radiusSlider.isUserInteractionEnabled = true
    }
}
