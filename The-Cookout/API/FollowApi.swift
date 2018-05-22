//
//  FollowApi.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import Foundation
import FirebaseDatabase
class FollowApi {
    var refFollowers = Database.database().reference().child("followers")
    var refFollowingG = Database.database().reference().child("following")
    
    func followAction(withUser id: String) {
        Api.myPosts.myPostsRef.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child((Api.user.currentUser?.uid)!).child(key).setValue(true)
                }
            }
        })
        refFollowers.child(id).child(Api.user.currentUser!.uid).setValue(true)
        refFollowingG.child(Api.user.currentUser!.uid).child(id).setValue(true)
    }
    
    func unFollowAction(withUser id: String) {
        
        Api.myPosts.myPostsRef.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Api.user.currentUser!.uid).child(key).removeValue()
                }
            }
        })
        
        refFollowers.child(id).child(Api.user.currentUser!.uid).setValue(NSNull())
        refFollowingG.child(Api.user.currentUser!.uid).child(id).setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        refFollowers.child(userId).child(Api.user.currentUser!.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        })
    }
    
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        refFollowingG.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        refFollowers.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
}
