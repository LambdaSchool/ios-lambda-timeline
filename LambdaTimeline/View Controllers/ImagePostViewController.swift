//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Photos

enum FilterType {
    case blackAndWhite
    case blur
    case negative
    case sepia
    case sharpen
}

class ImagePostViewController: ShiftableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    
    // MARK: - Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var context = CIContext(options: nil)
    var filterType: FilterType!
    
    private var originalImage: UIImage? {
        didSet {
            // TODO: - Original Image -> Scaled Image
            guard let originalImage = originalImage else { return }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageViewHeight(with: 1.0)
        updateViews()
    }
    
    // MARK: - Functions
    
    func updateViews() {
        guard let imageData = imageData, let image = UIImage(data: imageData) else {
            title = "New Post"
            return
        }
        
        title = post?.title
        setImageViewHeight(with: image.ratio)
        imageView.image = image
        chooseImageButton.setTitle("", for: [])
    }
    
    func filter(_ image: UIImage, for type: FilterType) -> UIImage? {
        switch type {
        case .sepia:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.sepiaTone()
            filter.inputImage = ciImage
            filter.intensity = slider.value
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .blackAndWhite:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = ciImage
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .blur:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage
            filter.radius = slider.value
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .sharpen:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = ciImage
            filter.sharpness = slider.value
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        case .negative:
            guard let cgImage = image.cgImage else { return nil }
            let ciImage = CIImage(cgImage: cgImage)
            let filter = CIFilter.colorInvert()
            filter.inputImage = ciImage
            guard let outputCIImage = filter.outputImage else { return nil }
            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
            return UIImage(cgImage: outputCGImage)
        }
    }
    
    // MARK: - Private Functions
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            switch self.filterType {
            case .sepia:
                imageView.image = filter(scaledImage, for: .sepia)
            case .blackAndWhite:
                imageView.image = filter(scaledImage, for: .blackAndWhite)
            case .blur:
                imageView.image = filter(scaledImage, for: .blur)
            case .sharpen:
                imageView.image = filter(scaledImage, for: .sharpen)
            case .negative:
                imageView.image = filter(scaledImage, for: .negative)
            case .none:
                break
            }
        } else {
            imageView.image = nil
        }
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        @unknown default:
            print("FatalError")
        }
        presentImagePickerController()
    }
    
    @IBAction func blurTapped(_ sender: UIButton) {
        originalImage = imageView.image
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 0
        filterType = .blur
    }
    
    @IBAction func invertTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueLabel.removeFromSuperview()
        slider.removeFromSuperview()
        filterType = .negative
        updateImage()
    }
    
    @IBAction func blackAndWhiteTapped(_ sender: UIButton) {
        originalImage = imageView.image
        valueLabel.removeFromSuperview()
        slider.removeFromSuperview()
        filterType = .blackAndWhite
        updateImage()
    }
    
    @IBAction func sharpenTapped(_ sender: UIButton) {
        originalImage = imageView.image
        slider.minimumValue = 0
        slider.maximumValue = 2
        slider.value = 0.4
        filterType = .sharpen
    }
    
    @IBAction func sepiaTapped(_ sender: UIButton) {
        originalImage = imageView.image
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        filterType = .sepia
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = image
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
