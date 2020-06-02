//
//  ImagePostViewController.swift
//  PhotoFilterEditor
//
//  Created by Bhawnish Kumar on 6/1/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {
    
    let context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {
            //            updateViews()
            guard let originalImage = originalImage else {
                scaledImage = nil // clear out image if set to nil
                return
            }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBOutlet weak var choosePhotoOutlet: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurRadiusSlider: UISlider!
    @IBOutlet weak var bumpRadiusSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        choosePhotoOutlet.layer.cornerRadius = 12
        // Do any additional setup after loading the view.
        let filter = CIFilter.colorControls()
        filter.brightness = 1
        print(filter.attributes)
        
        originalImage = imageView.image
    }
    
    private func filterImage(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.colorControls()
        filter.setValue(cgImage, forKey: kCIInputImageKey)
        filter.brightness = brightnessSlider.value
        filter.saturation = saturationSlider.value
        filter.contrast = contrastSlider.value
        filter.inputImage = ciImage
        
        guard let blurImage = filter.outputImage else { return nil }
        let blur = CIFilter.motionBlur()
        blur.setValue(blurImage, forKey: kCIInputImageKey)
        blur.setValue(blurRadiusSlider.value, forKey: kCIInputRadiusKey)
        
        guard let bumpImage = blur.outputImage else { return nil }
        let bump = CIFilter(name: "CIBumpDistortion")!
        bump.setValue(bumpImage, forKey: kCIInputImageKey)
        bump.setValue(CIVector(cgPoint: CGPoint(x: 150, y: 150)), forKey: kCIInputCenterKey)
        bump.setValue(bumpRadiusSlider.value, forKey: kCIInputRadiusKey)
        
        guard let outputCIImage = bump.outputImage else { return nil }
        
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else {
                                                            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func presentPickerType() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print(" picker view controller not available")
            return
        }
        
        let imagePickerView = UIImagePickerController()
        imagePickerView.sourceType = .photoLibrary
        imagePickerView.delegate = self
        
        present(imagePickerView, animated: true, completion: nil)
        
        
    }
    
    private func saveAndFilterPhoto() {
        guard let originalImage = originalImage else { return }
        
        guard let processedImage = filterImage(originalImage.flattened) else { return }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else { return } // TODO: Handle other cases
            //        as long as we are authorized then we are able to do changes
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
                
            }) { (success, error) in
                if let error = error {
                    print("error saving photo: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    print("saved photo")
                }
            }
        }
        
        
    }
    
    private func updateViews() {
        guard let scaledImage = scaledImage else { return }
        imageView.image = filterImage(scaledImage)
    }
    
    @IBAction func brightnessSlider(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func contrastSlider(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func saturationSlider(_ sender: UISlider) {
        updateViews()
    }
    @IBAction func blurRadiusSlider(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func bumpRadiusSlider(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func savePhotoButton(_ sender: UIButton) {
        saveAndFilterPhoto()
    }
    @IBAction func choosePhotoButton(_ sender: UIBarButtonItem) {
presentPickerType()
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

extension ImagePostViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
         picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true)
    }
    
}
extension ImagePostViewController: UINavigationControllerDelegate {
    
}
