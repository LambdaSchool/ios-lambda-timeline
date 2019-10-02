//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreImage
import Photos

class ImagePostViewController: ShiftableViewController {
    
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    let hueFilter = CIFilter(name: "CIHueAdjust")!
    let monoFilter = CIFilter(name: "CIPhotoEffectMono")!
    let transferFilter = CIFilter(name: "CIPhotoEffectTransfer")!
    let sepiaFilter = CIFilter(name: "CISepiaTone")!
    let invertFilter = CIFilter(name: "CIColorInvert")!
    
    private let context = CIContext(options: nil)
    
    private var originalImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageViewHeight(with: 1.0)
        updateViews()
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
            
        }
        presentImagePickerController()
    }
    
    @IBAction func hueButtonTapped(_ sender: Any) {
       
    }
    @IBAction func monoButtonTapped(_ sender: Any) {
    }
    @IBAction func sepiaButtonTapped(_ sender: Any) {
         updateImage()
    }
    
    @IBAction func invertButtonTapped(_ sender: Any) {
    }
    @IBAction func transferButtonTapped(_ sender: Any) {
    }
    func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        title = post?.title
        setImageViewHeight(with: image.ratio)
        imageView.image = image
        chooseImageButton.setTitle("", for: [])
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
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    
    func updateImage() {
        guard let originalImage = originalImage   else {return}
        var maxSize = imageView.bounds.size
        let scale = UIScreen.main.scale
        
        maxSize = CGSize(width: maxSize.width * scale,
                            height: maxSize.height * scale)

        guard let scaledImage = originalImage.imageByScaling(toSize: maxSize) else {return}
            imageView?.image = filterSepia(image: scaledImage)
    }
    
    func filterSepia(image: UIImage) -> UIImage? {

        guard let cgImage = image.cgImage else {return image}
        let ciImage = CIImage(cgImage: cgImage)
        sepiaFilter.setValue(ciImage, forKey: kCIInputIntensityKey)
        guard let outputCIImage = sepiaFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {return nil}
        return UIImage(cgImage: outputCGImage)
    }
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
