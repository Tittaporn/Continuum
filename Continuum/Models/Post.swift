//
//  Post.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

struct PostStrings {
    static let recordTypeKey = "Post"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let captionKey = "caption"
    fileprivate static let photoAssetKey = "photo"
    fileprivate static let commentCountKey = "commentCount"
}

struct CommentStrings {
    static let recordTypeKey = "Comment"
    fileprivate static let textKey = "text"
    fileprivate static let timestampKey = "timestamp"
    static let postReferenceKey = "postReference"
}
//let text: String
//let timestamp: Date
//weak var post: Post?
//let recordID: CKRecord.ID

class Post {
    var photoData: Data?
    let timestamp: Date
    let caption: String
    var comments: [Comment]
    var commentCount: Int
   let recordID: CKRecord.ID
    var photo: UIImage? {
        get {
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
            
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoAsset: CKAsset? {
        get {
            guard photoData != nil else { return nil}
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    

    init(timestamp: Date = Date(), caption: String, comments: [Comment] = [],commentCount: Int = 0 ,photo: UIImage?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.commentCount = commentCount
        self.recordID = recordID
        self.photo = photo
    }
}

class Comment {
    let text: String
    let timestamp: Date
   
    let recordID: CKRecord.ID
    weak var post: Post?

    //Add a computed property of types CKRecord.Reference? to the comment class. This should return a new CKRecord.Reference using the comment’s post object
    var postReference: CKRecord.Reference? {
        guard let post = post else {return nil}
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }

    //{
//        return Comment??
//    }
    
    init(text: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), post: Post?) { //}, postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
       // self.postReference = postReference
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentStrings.recordTypeKey, recordID: comment.recordID)
        setValuesForKeys([
            CommentStrings.textKey: comment.text,
            CommentStrings.timestampKey: comment.timestamp
        ])
        if let postReference = comment.postReference {
            setValue(postReference, forKey: CommentStrings.postReferenceKey)
        }
    }
}


extension Comment {
    convenience init?(ckRecord: CKRecord, post: Post?) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
              let timestamp = ckRecord[CommentStrings.timestampKey] as? Date else {return nil}
       // var foundPost: Post?
        
//        if let postReference = ckRecord[CommentStrings.postReferenceKey] as? CKRecord.Reference {
//            foundPost = postReference
//        }
  // let postReference = ckRecord[CommentStrings.postReferenceKey] as? CKRecord.Reference
//        if post != nil {
//
//        }
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, post: post)
    }
}
// This protocol only for example, for performing the function in the class, we can use in any class to inheritance from the protocol.
extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if self.caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}

// That why Don't need the delegate
// weak var delegate = SearchableRecord()?
//..delegate = self.

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostStrings.recordTypeKey, recordID: post.recordID)
        self.setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.commentCountKey : post.commentCount
        ])
        //Set the values of the CKRecord with the post’s properties. CloudKit only supports saving Foundational Types (save dictionaries) and will not allow saving UIImage or Comment instances. We will therefore need to save a CKAsset instead of an image. We will ignore comments for now, and come back to them using a process called back referencing    }
        if post.photoAsset != nil {
            setValue(post.photoAsset, forKey: PostStrings.photoAssetKey)
        }
    }
}

extension Post {
    convenience init?(ckRecord: CKRecord) {
        guard let timestamp = ckRecord[PostStrings.timestampKey] as? Date,
              let caption = ckRecord[PostStrings.captionKey] as? String,
              let commentCount = ckRecord[PostStrings.commentCountKey] as? Int else {return nil}
        // add photo
        var foundPhoto: UIImage?
        
        // if foundPhoto is nil.... then don't run this block
        if let photoAsset = ckRecord[PostStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!) //! make your app crash if value is nil.
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could Not Transform Asset to Data")
            }
        }
        self.init(timestamp: timestamp, caption: caption, comments: [], commentCount: commentCount, photo: foundPhoto, recordID: ckRecord.recordID)
    }
}


//var photoData: Data?
//let timestamp: Date
//let caption: String
//var comments: [Comment]
//var recordID: CKRecord.ID
//var photo: UIImage? {
