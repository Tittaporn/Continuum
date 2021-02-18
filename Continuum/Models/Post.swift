//
//  Post.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

// MARK: - Magic Strings
struct PostStrings {
    static let recordTypeKey = "Post"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let captionKey = "caption"
    fileprivate static let photoAssetKey = "photo"
    fileprivate static let commentCountKey = "commentCount"
}

// MARK: - Post
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

// MARK: - CKRecord(init Post)
extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostStrings.recordTypeKey, recordID: post.recordID)
        self.setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.commentCountKey : post.commentCount
        ])
        if post.photoAsset != nil {
            setValue(post.photoAsset, forKey: PostStrings.photoAssetKey)
        }
    }
}

// MARK: - Post(init ckRecord)
extension Post {
    convenience init?(ckRecord: CKRecord) {
        guard let timestamp = ckRecord[PostStrings.timestampKey] as? Date,
              let caption = ckRecord[PostStrings.captionKey] as? String,
              let commentCount = ckRecord[PostStrings.commentCountKey] as? Int else {return nil}
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[PostStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could Not Transform Asset to Data")
            }
        }
        self.init(timestamp: timestamp, caption: caption, comments: [], commentCount: commentCount, photo: foundPhoto, recordID: ckRecord.recordID)
    }
}

// MARK: - SearchableRecord Protocol
extension Post: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if self.caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}
