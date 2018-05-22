//
//  MyPostsApi.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation

import Foundation
import FirebaseDatabase
class MyPostsApi {
    var myPostsRef = Database.database().reference().child("myPosts")
    
    func fetchMyPosts(userId: String, completion: @escaping (String) -> Void) {
        myPostsRef.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        myPostsRef.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
