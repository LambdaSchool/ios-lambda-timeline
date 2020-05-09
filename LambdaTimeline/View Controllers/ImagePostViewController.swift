//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    // MARK: - Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var originalImage: UIImage? {
        didSet { reducedImage = reduce(originalImage) }
    }
    var reducedImage: UIImage? {
        didSet { updateImageView() }
    }
    var filter: CIFilter? {
        didSet { setupFilterUI(); updateImageView(); print(filter?.attributes ?? "") }
    }
    
    private let context = CIContext(options: nil)
    private var sliders: [FilterSlider] = []
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var controlStackView: UIStackView!
    @IBOutlet weak var addFilterButton: UIButton!
    @IBOutlet weak var geotagSwitch: UISwitch!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        titleTextField.delegate = self
        updateViews()
    }
    
    // MARK: - UI Actions
    @IBAction func createPost(_ sender: Any) {
        view.endEditing(true)
        postButton.isEnabled = false
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        let geotag = geotagSwitch.isOn ? LocationHelper.shared.currentLoction?.coordinate : nil
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio, geotag: geotag) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                    self.postButton.isEnabled = true
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        PhotoLibraryHelper.shared.checkAuthorizationStatus { (alertController) in
            if let alertController = alertController {
                self.present(alertController, animated: true)
            } else {
                self.presentImagePickerController()
            }
        }
    }
    
    @IBAction func changeGeotagPreference(_ sender: UISwitch) {
        if sender.isOn {
            LocationHelper.shared.requestAccess() { granted in
                if !granted {
                    DispatchQueue.main.async {
                        let alert = UIAlertController.informationalAlertController(message: "You can't geotag the post if you don't give permission to use your location.")
                        self.present(alert, animated: true)
                        sender.isOn = false
                    }
                }
            }
        }
    }
    
    @IBAction func addFilter(_ sender: Any) {
        presentFilterAlert()
    }
    
    // MARK: - Utility Methods
    private func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                updateAddFilterButton()
                return
        }
        
        title = post?.title
        setImageViewHeight(with: image.ratio)
        originalImage = image
        chooseImageButton.setTitle("", for: [])
    }
    
    private func setImageViewHeight(with aspectRatio: CGFloat) {
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        view.layoutSubviews()
    }
    
    private func updateAddFilterButton() {
        addFilterButton.isHidden = imageView.image == nil
    }
    
    @objc private func updateImageView() {
        guard let image = reducedImage else { return }
        
        imageView.image = applyFilter(to: image)

        updateAddFilterButton()
    }
    
    private func applyFilter(to image: UIImage) -> UIImage {
        guard let filter = filter,
        let inputImage: CIImage = image.getCIImage() else { return image }
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        for slider in sliders {
            filter.setValue(slider.value, forKey: slider.attributeName)
        }
        
        guard let outputImage = filter.outputImage,
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }

        return UIImage(cgImage: cgImage)
    }
    
    private func reduce(_ image: UIImage?) -> UIImage? {
        guard let inputImage: CIImage = image?.getCIImage() else { return image }
        
        let scale = 800 / max(inputImage.extent.size.width, inputImage.extent.size.height)
        if scale < 1 {
            let scaleFilter = CIFilter(name: "CILanczosScaleTransform")!
            scaleFilter.setValue(inputImage, forKey: kCIInputImageKey)
            scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
            guard let outputImage = scaleFilter.outputImage,
                let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return image }
            
            return UIImage(cgImage: cgImage)
        }
        return image
    }
    
    private func setupFilterUI() {
        for slider in sliders {
            controlStackView.removeArrangedSubview(slider.view)
            slider.view.removeFromSuperview()
        }
        
        guard let filter = filter else { return }
        
        sliders = filter.attributes.compactMap { (key, value) -> FilterSlider? in
            return FilterSlider(name: key, attributes: value)
            }.sorted {
                $0.displayName < $1.displayName
        }
        
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        for filterSlider in sliders {
            controlStackView.addArrangedSubview(filterSlider.view)
            
            let slider = filterSlider.slider
            
            let equalWidth = slider.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor)
            equalWidth.isActive = true
            
            slider.addTarget(self, action: #selector(updateImageView), for: .valueChanged)
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
    
    private func presentFilterAlert() {
        let alert = UIAlertController(title: "Add Filter", message: "Which kind of filter do you want to add?", preferredStyle: .actionSheet)
        
        for (title, filter) in supportedFilters {
            let action = UIAlertAction(title: title, style: .default) { (_) in
                self.reducedImage = self.imageView.image
                self.filter = filter
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        
        if filter != nil {
            let removeFiltersAction = UIAlertAction(title: "Remove Filter", style: .destructive) { (_) in
                self.filter = nil
            }
            alert.addAction(removeFiltersAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UI Image Picker Controller Delegate
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        originalImage = image
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagePostViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
