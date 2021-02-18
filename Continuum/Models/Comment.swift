//
//  Comment.swift
//  Continuum
//
//  Created by Lee McCormick on 2/18/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

// MARK: - Comment Magic Strings
struct CommentStrings {
    static let recordTypeKey = "Comment"
    fileprivate static let textKey = "text"
    fileprivate static let timestampKey = "timestamp"
    static let postReferenceKey = "postReference"
}

// MARK: - Comment
class Comment {
    let text: String
    let timestamp: Date
    let recordID: CKRecord.ID
    weak var post: Post?
    var postReference: CKRecord.Reference? {
        guard let post = post else {return nil}
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }

    init(text: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), post: Post?) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
    }
}

// MARK: - CKRecord(init comment)
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

// MARK: - Comment(init ckRecord)
extension Comment {
    convenience init?(ckRecord: CKRecord, post: Post?) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
              let timestamp = ckRecord[CommentStrings.timestampKey] as? Date else {return nil}
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, post: post)
    }
}


