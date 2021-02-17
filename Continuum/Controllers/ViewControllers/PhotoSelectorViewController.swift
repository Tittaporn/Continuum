//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/3/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

protocol PhotoSelectorViewControllerDelegate: AnyObject {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectedImageButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    // MARK: - Life Cycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            postImageView.image = nil
            selectedImageButton.setTitle("Select Photo", for: .normal)
        }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        postImageView.image = nil
        selectedImageButton.setTitle("Select Photo", for: .normal)
    }
    
    
    // MARK: - Actions
    @IBAction func selectedImageButtonTapped(_ sender: Any) {
        presentAlertUserSelectImage()
    }
    
    func presentAlertUserSelectImage() {
        let alertController = UIAlertController(title: "Select Image!", message: "from your photo library or camera.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let selectedImageFromPhotoLibrary = UIAlertAction(title: "Photo Library", style: .destructive) { (_) in
            self.pickAnImage(sourceType: .photoLibrary)
        }
        let selectedImageFromCamera = UIAlertAction(title: "Camera", style: .destructive) { (_) in
           self.pickAnImage(sourceType: .camera)
     }
        alertController.addAction(selectedImageFromPhotoLibrary)
        alertController.addAction(selectedImageFromCamera)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func pickAnImage(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        } else {
         presentAlertForNotAvailbleSourceType(sourceType: sourceType)
         }
    }
    
    func presentAlertForNotAvailbleSourceType(sourceType:         UIImagePickerController.SourceType) {
        let title =  sourceType == .camera ? "No Camera Access" : "No Photo Access"
        let message = sourceType == .camera ? "Plese allow access to the Camera to use this feature" : "Plese allow access to the Photos to use this feature"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
}


//MARK: - Delegate imagePickerController

extension PhotoSelectorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImageButton.setTitle("", for: .normal)
            postImageView.image = image
            delegate?.photoSelectorViewControllerSelected(image: image)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
