//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Chad Parker on 7/8/20.
//  Copyright © 2020 Chad Parker. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    // MARK: - Enums

    private enum Filter {
        case none, blur, colorControls
    }

    private enum State {
        case noPhoto
        case photoPicked(UIImage)
        case selectFilter(Filter)
    }

    // MARK: - Outlets

    @IBOutlet private var selectImageContainer: UIView!
    @IBOutlet private var selectImageButton: UIButton!

    @IBOutlet private var imageAndFilterStack: UIStackView!
    @IBOutlet private var imageView: UIImageView!

    @IBOutlet private var colorControlsButton: UIButton!
    @IBOutlet private var blurButton: UIButton!

    @IBOutlet private var colorControlsStack: UIStackView!
    @IBOutlet private var brightnessSlider: UISlider!
    @IBOutlet private var contrastSlider: UISlider!
    @IBOutlet private var saturationSlider: UISlider!

    @IBOutlet private var blurSlider: UISlider!
    

    // MARK: - Properties

    private var originalImage: UIImage?
    private var scaledImage: CIImage?
    private let context = CIContext()

    private let colorControlsFilter = CIFilter.colorControls()
    private let blurFilter = CIFilter.gaussianBlur()

    private var state: State = .noPhoto {
        didSet {
            stateChanged()
        }
    }


    // MARK: - View Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        selectImageButton.layer.cornerRadius = 16
        stateChanged()
    }

    private func deselectAllFilterButtons() {
        colorControlsButton.isSelected = false
        blurButton.isSelected = false
    }

    private func hideAllFilterSliders() {
        colorControlsStack.isHidden = true
        blurSlider.isHidden = true
    }

    private func updateImage() {
        guard let scaledImage = scaledImage else { return }

        imageView.image = image(byFiltering: scaledImage)
    }


    // MARK: - State Changes

    private func stateChanged() {
        switch state {

        case .noPhoto:
            originalImage = nil
            scaledImage = nil
            imageView.image = nil

            imageAndFilterStack.isHidden = true

        case .photoPicked(let chosenImage):
            originalImage = chosenImage
            scaledImage = CIImage(image: scale(image: chosenImage, to: imageView.bounds.size))
            imageView.image = UIImage(ciImage: scaledImage!)

            imageAndFilterStack.isHidden = false

        case .selectFilter(let chosenFilter):
            switch chosenFilter {
            case .none:
                deselectAllFilterButtons()
                hideAllFilterSliders()
            case .colorControls:
                deselectAllFilterButtons()
                hideAllFilterSliders()
                colorControlsButton.isSelected = true
                colorControlsStack.isHidden = false
            case .blur:
                deselectAllFilterButtons()
                hideAllFilterSliders()
                blurButton.isSelected = true
                blurSlider.isHidden = false
            }
        }
    }


    // MARK: - Actions

    @IBAction func selectImageTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available.")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self

        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func colorControlsSelected(_ sender: Any) {
        colorControlsButton.isSelected = true
        state = .selectFilter(.colorControls)
    }

    @IBAction func blurSelected(_ sender: UIButton) {
        blurButton.isSelected = true
        state = .selectFilter(.blur)
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        updateImage()
    }
    
    
    // MARK: - Image Processing
    
    private func scale(image: UIImage, to size: CGSize) -> UIImage {
        let screenScale = UIScreen.main.scale
        let sizeInPixels = CGSize(width: size.width * screenScale, height: size.height * screenScale)
        return image.imageByScaling(toSize: sizeInPixels)
    }

    private func image(byFiltering inputImage: CIImage) -> UIImage? {
        
        colorControlsFilter.inputImage = inputImage
        colorControlsFilter.saturation = saturationSlider.value
        colorControlsFilter.brightness = brightnessSlider.value
        colorControlsFilter.contrast = contrastSlider.value
        
        blurFilter.inputImage = colorControlsFilter.outputImage?.clampedToExtent()
        blurFilter.radius = blurSlider.value
        
        guard let outputImage = blurFilter.outputImage else { return nil }
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }
        return UIImage(cgImage: renderedCGImage)
    }
}


// MARK: - Image Picker Delegate

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[.editedImage] as? UIImage {
            state = .photoPicked(image)
        } else if let image = info[.originalImage] as? UIImage {
            state = .photoPicked(image)
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
