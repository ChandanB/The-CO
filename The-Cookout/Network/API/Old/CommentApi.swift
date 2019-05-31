//
//  CommentAPI.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    
    func observeComments(user: User, withPostId id: String, completion: @escaping (Comment) -> Void) {
        COMMENT_REF.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newComment = Comment(user: user, dictionary: dict)
                completion(newComment)
            }
        })
    }
}
