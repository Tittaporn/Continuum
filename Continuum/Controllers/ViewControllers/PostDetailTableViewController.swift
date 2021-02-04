//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet var photoImageView: UIImageView!
    
    
    // MARK: - Properties
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentCommentAlert()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        // Add an IBAction from the Share button in your PostDetailTableViewController if you have not already.
        //  Initialize a UIActivityViewController with the Post’s image and the caption as the shareable objects.
        // Present the UIActivityViewController.
        guard let post = post else {return}
        let postImage = post.photo
        let postCaption = post.caption
        
        
        let activityViewController = UIActivityViewController(activityItems: [postImage,postCaption], applicationActivities: nil)
        
        present(activityViewController, animated: true) {
            
        }
        
    }
    
    @IBAction func followPostButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: - Helper Fuctions
    func updateViews() {
        guard let post = post else { return }
        photoImageView.image = post.photo
    }
    
    func presentCommentAlert() {
        let alertController = UIAlertController(title: "Add Comment!", message: "What do you think about this continuum?", preferredStyle: .alert)
        alertController.addTextField { (textFiled) in
            textFiled.placeholder = "Add your comment here..."
            textFiled.autocorrectionType = .yes
            textFiled.autocapitalizationType = .sentences
        }
        
        let addAction = UIAlertAction(title: "OK", style: .destructive) { (_) in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty,
                  let post = self.post else { return }
            PostController.shared.addComment(text: text, post: post) { (result) in
                // Do something here.
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text ?? "No Comment"
        cell.detailTextLabel?.text = comment?.timestamp.dateToString(format: .fullNumericTimestamp) ?? "No Comment Time."
        return cell
    }
}
