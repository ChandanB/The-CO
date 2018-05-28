//
//  FeedApi.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostsApi {
    var postsRef = Database.database().reference().child("posts")
    
    func observePosts(user: User, withId id: String, completion: @escaping (Post) -> Void) {
        postsRef.child(id).observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            Api.post.observePost(user: user, withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func observePostsRemoved(user: User, withId id: String, completion: @escaping (Post) -> Void) {
        postsRef.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.post.observePost(user: user, withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
