//
//  ColorControlFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

protocol ColorControlFilterProtocol {
    func applyColorControlFilter() -> CIFilter
    
    var saturation: Double { get }
    var brightness: Double { get }
    var contrast: Double { get }
}
class ColorControlFilterViewController: UIViewController {

    
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var constrastSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        guard let image = image else { return }
        imageView.image = image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
