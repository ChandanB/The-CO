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
    let currentUser = CURRENT_USER

    var refCurrentUser: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return USER_REF.child(currentUser.uid)
    }

    // MARK: - Comment Functions
    let commentsRef = Database.database().reference().child("comments")

    // MARK: - Post Functions
    let postsRef = POSTS_REF

    func incrementLikes(user: User, postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = postsRef.child(postId)

        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in

            if var post = currentData.value as? [String: AnyObject], let uid = Auth.auth().currentUser?.uid {
                var hasLiked: Dictionary<String, Bool>
                hasLiked = post["likes"] as? [String: Bool] ?? [:]
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

        }) { (error, _, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post(user: user, dictionary: dict as [String: AnyObject])
                onSucess(post)
            }
        }
    }

    // MARK: - Follow Functions
    let followersRef = USER_FOLLOWER_REF
    let followingRef = USER_FOLLOWING_REF

}
