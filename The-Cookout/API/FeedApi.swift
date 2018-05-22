//
//  FeedApi.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedApi {
    var feedRef = Database.database().reference().child("feed")
    
    func observeFeed(user: User, withId id: String, completion: @escaping (Post) -> Void) {
        feedRef.child(id).observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            Api.post.observePost(user: user, withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func observeFeedRemoved(user: User, withId id: String, completion: @escaping (Post) -> Void) {
        feedRef.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.post.observePost(user: user, withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
