//
//  COAPI.swift
//  The-Cookout
//
//  Created by Chandan Brown on 4/30/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import Foundation
import Firebase

class SPDatabase {
    
    var hashtagRef = Database.database().reference().child("hashtag")
    
    // MARK: - User Functions
    let usersRef = Database.database().reference().child("users")
    
    let currentUser = Auth.auth().currentUser
    var refCurrentUser: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return usersRef.child(currentUser.uid)
    }
    
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        usersRef.queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in
            
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                guard let userDictionary = child.value as? [String: Any] else { return }
                let user = User(uid: snapshot.key, dictionary: userDictionary as [String : AnyObject])
                completion(user)
            })
        }
    }
    
    
    // MARK: - Comment Functions
    let commentsRef = Database.database().reference().child("comments")
    
    
    // MARK: - Post Functions
    let postsRef = Database.database().reference().child("posts")

    
    func queryPosts(user: User, withPosts posts: [Post], completion: @escaping (Post) -> Void) {
        var limit: UInt = 9
        var query = postsRef.child(user.uid).queryOrdered(byChild: "creationDate")
        
        if posts.last != nil {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            limit = 11
        }
        
        query.queryLimited(toLast: limit).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            
            if posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (s) in
                let child = s 
                guard let postDictionary = child.value as? [String: Any] else { return }
                let post = Post(user: user, dictionary: postDictionary as [String : AnyObject])
                completion(post)
            })
        }
    }

    
    func incrementLikes(user: User, postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = postsRef.child(postId)
        
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var hasLiked: Dictionary<String, Bool>
                hasLiked = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                
                if let _ = hasLiked[uid] {
                    likeCount -= 1
                    hasLiked.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    hasLiked[uid] = true
                }
                
                post["likeCount"] = likeCount as AnyObject?
                post["hasLiked"] = hasLiked as AnyObject?
                
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
    
    
    // MARK: - Follow Functions
    let followersRef = Database.database().reference().child("followers")
    let followingRef = Database.database().reference().child("following")
    
    
//    func fetchFollowers(userId: String, completion: @escaping ([User]) -> Void) {
//        followersRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
//            guard let followersDictionary = snapshot.value as? [String: Any] else { return }
//            var followersArray = [User]()
//            followersDictionary.forEach({ (key, value) in
//                self.fetchUserWithUID(uid: key, completion: { (user) in
//                    followersArray.append(user)
//                    completion(followersArray)
//                })
//            })
//        }
//    }
//    
//    func fetchFollowing(userId: String, completion: @escaping (User) -> Void) {
//        followingRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
//            guard let followingDictionary = snapshot.value as? [String: Any] else { return }
//            followingDictionary.forEach({ (key, value) in
//                self.fetchUserWithUID(uid: key, completion: { (user) in
//                    completion(user)
//                })
//            })
//        }
//    }
    
    
    let userMessagesRef = Database.database().reference().child("user-messages")
    func queryUserMessages(user: User, withMessages messages: [Message], completion: @escaping (Message) -> Void) {
        
        var limit: UInt = 20
        var query = userMessagesRef.child(user.uid).queryOrdered(byChild: "creationDate")
        
        if messages.last != nil {
            let value = messages.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            limit = 30
        }
        
        query.queryLimited(toFirst: limit).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            if messages.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (s) in
                let child = s
                guard let messagesDictionary = child.value as? [String: Any] else { return }
                let message = Message(dictionary: messagesDictionary as [String : AnyObject])
                completion(message)
            })
        }
    }
}
