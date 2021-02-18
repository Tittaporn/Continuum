//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - Life Cycle Methods
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    // MARK: - Properties
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Helper Fuctions
    func updateViews() {
        guard let post = post else { return }
        captionLabel.text = ("📸 \(post.caption)")
        commentLabel.text = ("Comments : \(post.commentCount)")
        postImageView.image = post.photo
    }
    
}
