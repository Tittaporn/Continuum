//
//  PostController.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import CloudKit
import UIKit

class PostController {
    // MARK: - Properties
    static let shared = PostController()
    var posts: [Post] = []
    // let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Methods
    // CREATE
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment,PostError>) -> Void){
        let newComment = Comment(text: text, post: post)
        post.comments.append(newComment)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?,PostError>) -> Void) {
        let newPost = Post(caption: caption, photo: image)
        posts.append(newPost)
    }
    
    // READ
    
    // UPDATE
    
    // DELETE
}
