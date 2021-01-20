//
//  User.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase

struct User: Comparable {

    let uid: String
    let bio: String
    let name: String
    let email: String
    let username: String
    var phoneNumber: String
    let bannerImageUrl: String
    let profileImageUrl: String
    var thumbnailPhotoURL: String

    var profileImage: UIImage
    var isFollowing: Bool
    var onlineStatus: AnyObject
    var isSelected: Bool! = false // local only

    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        self.profileImage = UIImage()
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.bannerImageUrl = dictionary["bannerImageUrl"] as? String ?? ""
        self.thumbnailPhotoURL = dictionary["thumbnailPhotoURL"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.onlineStatus = dictionary["OnlineStatus"] as AnyObject
        self.isFollowing = dictionary["isFollowing"] as? Bool ?? false
    }

    static func ==(lhs: User, rhs: User) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        return true
    }

    static func <(lhs: User, rhs: User) -> Bool {
        //...
        return false
    }
}

extension User { // local only
    var titleFirstLetter: String {
        return String(name[name.startIndex]).uppercased()
    }

    mutating func follow() {
        guard let currentUid = CURRENT_USER?.uid else { return }

        // set is followed to true
        self.isFollowing = true

        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])

        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])

        // upload follow notification to server
        uploadFollowNotificationToServer()

        // add followed users posts to current user-feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
    }

    mutating func unfollow() {
        guard let currentUid = CURRENT_USER?.uid else { return }

        self.isFollowing = false

        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()

        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()

        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
    }

    mutating func addPosts(followedUser: String, loggedInUser: String) {
        USER_POSTS_REF.child(followedUser).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {return}
            USER_FEED_REF.child(loggedInUser).updateChildValues(dict)
        }
    }

    mutating func removePosts(followedUser: String, loggedInUser: String) {
        USER_POSTS_REF.child(followedUser).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {return}
            for key in dict.keys {
                USER_FEED_REF.child(loggedInUser).child(key).removeValue()
            }
        }
    }


    func uploadFollowNotificationToServer() {

        guard let currentUid = CURRENT_USER?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)

        // notification values
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FOLLOW_INT_VALUE] as [String: Any]

        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
    }
}
