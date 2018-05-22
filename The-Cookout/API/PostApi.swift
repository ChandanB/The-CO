//
//  PostAPI.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import FirebaseDatabase

class PostApi {
    var postsRef = Database.database().reference().child("posts")
    
    func observePosts(user: User, completion: @escaping (Post) -> Void) {
        postsRef.observe(.childAdded) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else {return}
            dict.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                completion(post)
            })
        }
    }
    
    func observePost(user: User, withId id: String, completion: @escaping (Post) -> Void) {
        postsRef.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post(user: user, dictionary: dict as [String : AnyObject])
                completion(post)
            }
        })
    }
    
    func observeLikeCount(withPostId id: String, completion: @escaping (Int, UInt) -> Void) {
        var likeHandler: UInt!
        likeHandler = postsRef.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int {
                completion(value, likeHandler)
            }
        })
    }
    
    func observeTopPosts(user: User, completion: @escaping (Post) -> Void) {
        postsRef.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post(user: user, dictionary: dict as [String : AnyObject])
                    completion(post)
                }
            })
        })
    }
    
    func removeObserveLikeCount(id: String, likeHandler: UInt) {
        Api.post.postsRef.child(id).removeObserver(withHandle: likeHandler)
    }
    
    
    func incrementLikes(user: User, postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = Api.post.postsRef.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.user.currentUser?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post(user: user, dictionary: dict as [String : AnyObject])
                onSucess(post)
            }
        }
    }
    
}

