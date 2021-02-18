//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import Photos

class AddPostTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var postCaptionTextField: UITextField!
    
    // MARK: - Properties
    var selectedImage: UIImage?
    
    // MARK: - Outlets
    override func viewDidDisappear(_ animated: Bool) {
        postCaptionTextField.text = nil
    }
    
    // MARK: - Actions
    @IBAction func addPostButtonTapped(_ sender: Any) {
        if let postImage = selectedImage, let caption = postCaptionTextField.text, !caption.isEmpty {
            PostController.shared.createPostWith(image: postImage, caption: caption) { (_) in
            }
            addPhotoToContiuumAlbum()
            self.tabBarController?.selectedIndex = 0
        } else if selectedImage == nil , let caption = postCaptionTextField.text, !caption.isEmpty {
            presentErrorToUser(textAlert:"You need to add an image!!")
            
        } else if selectedImage != nil , let caption = postCaptionTextField.text, caption.isEmpty{
            presentErrorToUser(textAlert:"You need add a caption!!")
            
        } else {
            presentErrorToUser(textAlert: "You need to add both you fool!")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostSelectedImageVC" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
    }
}


//MARK: - Extensions
extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
}

//MARK: - PHPHotoLibraryChangeObserver & PhotoKit Methods
extension AddPostTableViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("Photo Library did Change")
    }
    
    func createContinuumAlbum(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().register(self)
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Continuum")
        }, completionHandler: { success, error in
            completion(success)
            if !success { print("Error creating album: \(String(describing: error)).") }
        })
    }
    
    func insert(photo: UIImage, in collection: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
            let addAssetRequest = PHAssetCollectionChangeRequest(for: collection)
            addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
        }, completionHandler: nil)
    }
    
    func fetchContinuumAlbum() ->  PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "Continuum")
        let assetfetchResults = PHAssetCollection.fetchAssetCollections(with: .album, subtype: PHAssetCollectionSubtype.any, options: fetchOptions)
        return assetfetchResults.firstObject
    }
    
    func addPhotoToContiuumAlbum() {
        guard let photo = selectedImage else { return }
        if let contiuumCollection = self.fetchContinuumAlbum() {
            self.insert(photo: photo, in: contiuumCollection)
        } else {
            self.createContinuumAlbum(completion: { (success) in
                guard success, let album = self.fetchContinuumAlbum() else { return }
                self.insert(photo: photo, in: album)
            })
        }
    }
}
