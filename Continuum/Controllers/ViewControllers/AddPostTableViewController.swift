//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

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
//    @IBAction func selectedImageButtonTapped(_ sender: Any) {
//        postCaptionTextField.text = ""
//    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        if let postImage = selectedImage, let caption = postCaptionTextField.text, !caption.isEmpty {
            
            PostController.shared.createPostWith(image: postImage, caption: caption) { (_) in
            }
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
        if segue.identifier == "toAddPostVC" {
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





