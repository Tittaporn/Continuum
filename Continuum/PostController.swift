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
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD Methods
    // CREATE
    func addComment(text: String, post: Post, completion: @escaping (Result<Comment,PostError>) -> Void){
        let newComment = Comment(text: text, post: post)
        
        post.comments.append(newComment)
        let commentRecord = CKRecord(comment: newComment)
        publicDB.save(commentRecord) { (record, error) in
            if let error = error  {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError))
            }
            guard let record = record,
                  let savedComment = Comment(ckRecord: record, post: post) else {return completion(.failure(.unableToUpwrap))}
     
            self.incrementCommentCountForEachPost(post: post, completion: nil)
            print("Successfully saved a comment in the Cloud.")
            completion(.success(savedComment))
        }
        
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?,PostError>) -> Void) {
        let newPost = Post(caption: caption, photo: image)
        let postRecord = CKRecord(post: newPost)
        publicDB.save(postRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return completion(.failure(.ckError))
                }
                guard let record = record ,
                      let savedPost = Post(ckRecord: record) else {return completion(.failure(.unableToUpwrap))}
                self.posts.append(savedPost)
                print("Succuessfully saved a Post in the Cloud.")
                completion(.success(savedPost))
            }
        }
       
    }
    
    // READ
    func fetchPosts(completion: @escaping (Result<[Post]?,PostError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PostStrings.recordTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
           
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError))
            }
            guard let records = records else {return completion(.failure(.unableToUpwrap))}
                let fetchAllPosts = records.compactMap { Post(ckRecord: $0)}
                self.posts = fetchAllPosts
                print("Succesfully fetched all posts.")
                completion(.success(fetchAllPosts))
            }
        }
        
    }
    
    func fetchComments(for post: Post, completion: @escaping (Result<[Comment]?,PostError>) -> Void) {
       // let predicate = NSPredicate(value: true)
        
        
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.postReferenceKey, postReference)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])

       // let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        let query = CKQuery(recordType: CommentStrings.recordTypeKey, predicate: compoundPredicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
         
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError))
            }
                guard let records = records else {return completion(.failure(.unableToUpwrap))}
                let fetchCommentsOfPost = records.compactMap { Comment(ckRecord: $0, post: post)}
                
                post.comments = fetchCommentsOfPost
                print("Successfully fetch comments for each post.")
                completion(.success(fetchCommentsOfPost))
            }
            
        }
    }
    
    // UPDATE
    func incrementCommentCountForEachPost(post: Post,completion: ((Bool) -> Void)?) {
        post.commentCount += 1
        let postForUpdate = CKRecord(post: post)
        let operation = CKModifyRecordsOperation(recordsToSave: [postForUpdate], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.modifyRecordsCompletionBlock = {records, recordIDs, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
               
                    completion?(false)
                return
            }
            guard let record = records?.first else {
                completion?(false)
                return
            }
            print("Successfully add commentCount in the CouldKit of \(record.recordID.recordName)")
            completion?((true))
        }
        publicDB.add(operation)
    }
    
    
    // DELETE
}
