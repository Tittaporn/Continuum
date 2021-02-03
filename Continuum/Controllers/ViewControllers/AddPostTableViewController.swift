//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaptionTextField: UITextField!
    @IBOutlet weak var selectedImageButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewsForPost()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        configureViewsForPost()
    }
    
    
    func configureViewsForPost() {
        selectedImageButton.setTitle("Selected Image", for: .normal)
        postImageView.image = nil
        postCaptionTextField.text = ""
    }
    
    // MARK: - Actions
    @IBAction func selectedImageButtonTapped(_ sender: Any) {
        postImageView.image = UIImage(named: "spaceEmptyState")
        postCaptionTextField.text = ""
        
        //        selectedImageButton.setTitle("Selected Image", for: .normal)
        //        postCaptionTextField.text = ""
        //        postImageView.image = nil
        //configureViewsForPost()
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        if let postImage = postImageView.image, let caption = postCaptionTextField.text, !caption.isEmpty {
            
            PostController.shared.createPostWith(image: postImage, caption: caption) { (_) in
            }
            self.tabBarController?.selectedIndex = 0
            
        } else if postImageView.image == nil , let caption = postCaptionTextField.text, !caption.isEmpty {
            presentErrorToUser(textAlert:"You need to add an image!!")
            
        } else if postImageView.image != nil , let caption = postCaptionTextField.text, caption.isEmpty{
            presentErrorToUser(textAlert:"You need add a caption!!")
            
        } else {
            presentErrorToUser(textAlert: "You need to add both you fool!")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
}
