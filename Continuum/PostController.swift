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
    // MARK: - CloudKit Subscriptions
    // SUBSCRIBE
    func subscribeToNewPosts(completion: ((Bool,Error?)->Void)?){
        let allPostsPredicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: PostStrings.recordTypeKey, predicate: allPostsPredicate,subscriptionID: "AllPosts", options: .firesOnRecordUpdate)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "POST! A POST IS IN!"
        notificationInfo.alertBody = "Can't catch up enough POSTS in Continuum!"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false,error)
            }
            completion?(true,nil)
        }
        
    }
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool,Error?) -> ())?) {
        
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.postReferenceKey, postReference)
//        let commentIDs = post.comments.compactMap({$0.recordID})
//        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let subscription = CKQuerySubscription(recordType: CommentStrings.recordTypeKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: .firesOnRecordCreation)

            //CKQuerySubscription(recordType: CommentStrings.recordTypeKey, predicate: compoundPredicate,)
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Comments! Updated in a POST you followed!"
        notification.shouldSendContentAvailable = true
       notification.desiredKeys = nil
        subscription.notificationInfo = notification
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false,error)
            }
            completion?(true,nil)
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool) -> ())?) {
        let ckSubscriptionID = post.recordID.recordName
        publicDB.delete(withSubscriptionID: ckSubscriptionID) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
               completion?(false)
                return
            }
            print("Successfully removed subscrption to comment. Subscription Deleted!")
         completion?(true)
        }
    }
    
    func checkSubscription(to post: Post, completion: ((Bool) -> ())?) {
        let subscriptionID = post.recordID.recordName
        publicDB.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion?(false)
                return
            }
            if subscription != nil {
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: ((Bool,Error?) -> ())?) {
        checkSubscription(to: post) { (isSubscripted) in
           // guard let isSubscripted = isSubscripted else {return}
            if isSubscripted {
                self.removeSubscriptionTo(commentsForPost: post) { (success) in
                    if success {
                        print("User subscripted to the post :\(post.caption) and now just removed subscription to comments for \(post.caption).")
                        completion?(true, nil)
                    } else {
                        print("Whoops somthing went wrong removing the subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                }
            } else {
                self.addSubscriptionTo(commentsForPost: post) { (success, error) in
                    if let error = error {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion?(false,nil)
                    }
                    if success {
                        print("User did not subscript to the post :\(post.caption) and now just added subscription to comments for \(post.caption).")
                        completion?(true,nil)
                    } else {
                        print("Whoops somthing went wrong adding the subscription to the post with caption: \(post.caption)")
                        completion?(false, nil)
                    }
                }
            }
        }
    }
    
}
