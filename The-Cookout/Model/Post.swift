//
//  Post.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase

class Post: Content {
    var contentType: ContentType
    var id: String!
    var userId: String!
    var user: User!

    var caption: String
    var imageUrl: String
    var videoUrl: String

    var hasText: Bool
    let hasImage: Bool

    var repostedByCurrentUser: Bool = false
    var repostCount: Int = 0
    var reposts: Dictionary<String, Any>

    var upvotedByCurrentUser: Bool = false
    var upvotes: Int!

    var downvotedByCurrentUser: Bool = false
    var downvotes: Int!

    var overallVoteCount: Int = 0

    let creationDate: Date
    let timestamp: NSNumber

    var ratio: CGFloat
    let imageWidth: NSNumber
    let imageHeight: NSNumber

    init(id: String, user: User, dictionary: [String: Any]) {
        self.contentType = .post
        self.id = id
        self.user = user
        self.userId = user.uid

        self.caption = dictionary["caption"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.videoUrl = dictionary["videoUrl"] as? String ?? ""

        self.hasText = dictionary["hasText"] as? Bool ?? false
        self.hasImage = dictionary["hasImage"] as? Bool ?? false

        self.repostedByCurrentUser = dictionary["repostedByCurrentUser"] as? Bool ?? false
        self.repostCount = dictionary["repostCount"] as? Int ?? 0
        self.reposts = dictionary["reposts"] as? Dictionary ?? ["": 0]

        self.upvotedByCurrentUser = dictionary["upvotedByCurrentUser"] as? Bool ?? false
        if let upvotes = dictionary["upvotes"] as? Int {
            self.upvotes = upvotes
        }

        self.downvotedByCurrentUser = dictionary["downvotedByCurrentUser"] as? Bool ?? false
        if let downvotes = dictionary["downvotes"] as? Int {
            self.downvotes = downvotes
        }

        self.overallVoteCount = dictionary["overallVoteCount"] as? Int ?? 0

        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.timestamp = dictionary["timestamp"] as? NSNumber ?? 0

        self.ratio = dictionary["ratio"] as? CGFloat ?? 0
        self.imageWidth = dictionary["imageWidth"] as? NSNumber ?? 0
        self.imageHeight = dictionary["imageHeight"] as? NSNumber ?? 0

    }
}

extension Post {
    static func transformPostPhoto(id: String, user: User, dict: [String: Any], key: String) -> Post {
        let post = Post(id: id, user: user, dictionary: dict as [String: AnyObject])
        post.id = key
        post.caption = dict["caption"] as? String ?? ""
        post.imageUrl = dict["imageUrl"] as? String ?? ""
        post.videoUrl = dict["videoUrl"] as? String ?? ""
        post.repostCount = dict["repostCount"] as? Int ?? 0
        post.reposts = dict["reposts"] as? Dictionary<String, Any> ?? ["": 0]
        post.ratio = dict["ratio"] as? CGFloat ?? 0
        if let currentUserId = CURRENT_USER?.uid {
            post.repostedByCurrentUser = post.reposts[currentUserId] != nil
        }
        return post
    }

    func calculateViewHeight(withView view: UIView, viewOffset: Int) -> CGFloat {
        let approxContentLabelSize = view.frame.width - 20
        let size = CGSize(width: approxContentLabelSize, height: 1000)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]

        let estimatedFrame = NSString(string: caption).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return estimatedFrame.height + CGFloat(viewOffset)
    }

    func adjustUpvotes(addVote: Bool, completion: @escaping((Int)->())) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if addVote {
            //update like from user-like structure
            let value = [id : 1]
            USER_VOTES_REF.child(currentUserId).updateChildValues(value) { (error, ref) in
                self.sendUpvoteNotificationToServer()
                //update like count
                POST_VOTES_REF.child(self.id).updateChildValues([currentUserId : 1]) { (error, ref) in
                    self.upvotes += 1
                    self.upvotedByCurrentUser = true
                    completion(self.upvotes)
                    POSTS_REF.child(self.id).updateChildValues(["upvotes" : self.upvotes])
                }
            }
        } else {
            USER_VOTES_REF.child(currentUserId).child(id).observeSingleEvent(of: .value) { (snapshot) in
                let notificationId = snapshot.key
                NOTIFICATIONS_REF.child(self.userId).child(notificationId).removeValue(completionBlock: { (error, ref) in
                    //remove like from user-like structure
                    USER_VOTES_REF.child(currentUserId).child(self.id).removeValue { (error, ref) in

                        //remove like from post-like structure
                        POST_VOTES_REF.child(self.id).child(currentUserId).removeValue { (error, ref) in
                            guard self.upvotes > 0 else {return}
                            self.upvotes -= 1
                            self.upvotedByCurrentUser = false
                            completion(self.upvotes)
                            POSTS_REF.child(self.id).updateChildValues(["upvotes" : self.upvotes])
                        }
                    }
                })
            }
        }
    }

    func adjustDownvotes(addVote: Bool, completion: @escaping((Int)->())) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if addVote {
            //update like from user-like structure
            let value = [id : 1]
            USER_DOWNVOTES_REF.child(currentUserId).updateChildValues(value) { (error, ref) in
                self.sendDownvoteNotificationToServer()
                //update like count
                POST_DOWNVOTES_REF.child(self.id).updateChildValues([currentUserId : 1]) { (error, ref) in
                    self.downvotes += 1
                    self.downvotedByCurrentUser = true
                    completion(self.downvotes)
                    POSTS_REF.child(self.id).updateChildValues(["downvotes" : self.downvotes])
                }
            }
        } else {
            USER_VOTES_REF.child(currentUserId).child(id).observeSingleEvent(of: .value) { (snapshot) in
                let notificationId = snapshot.key
                NOTIFICATIONS_REF.child(self.userId).child(notificationId).removeValue(completionBlock: { (error, ref) in
                    //remove like from user-like structure
                    USER_DOWNVOTES_REF.child(currentUserId).child(self.id).removeValue { (error, ref) in

                        //remove like from post-like structure
                        POST_DOWNVOTES_REF.child(self.id).child(currentUserId).removeValue { (error, ref) in
                            guard self.downvotes > 0 else {return}
                            self.downvotes -= 1
                            self.downvotedByCurrentUser = false
                            completion(self.downvotes)
                            POSTS_REF.child(self.id).updateChildValues(["downvotes" : self.downvotes])
                        }
                    }
                })
            }
        }
    }

    private func sendUpvoteNotificationToServer() {
        guard let currentUser = CURRENT_USER?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        let notificationRef = NOTIFICATIONS_REF.child(self.userId).childByAutoId()
        USER_VOTES_REF.child(userId).child(self.id).setValue(notificationRef.key)
        if currentUser == self.userId {return}
        let values : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currentUser, "type" : UPVOTE_INT_VALUE, "id" : id]
        notificationRef.updateChildValues(values)
    }

    private func sendDownvoteNotificationToServer() {
        guard let currentUser = CURRENT_USER?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        let notificationRef = NOTIFICATIONS_REF.child(self.userId).childByAutoId()
        USER_DOWNVOTES_REF.child(userId).child(self.id).setValue(notificationRef.key)
        if currentUser == self.userId {return}
        let values : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currentUser, "type" : DOWNVOTE_INT_VALUE, "id" : id]
        notificationRef.updateChildValues(values)
    }


    func deletePost() {
        guard let currentUser = CURRENT_USER?.uid else { return }

        //remove from storage
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)

        //deleting from other users feed by looking users in user-follower
        USER_FOLLOWER_REF.child(currentUser).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).child(self.id).removeValue()
        }

        //deleting from own user-feed structure
        USER_FEED_REF.child(currentUser).child(self.id).removeValue()

        //deleting from USER_POSTS_REF
        USER_POSTS_REF.child(currentUser).child(self.id).removeValue()

        //deleting from POST_VOTES_REF, userLikesRef and notificationsRef by accessing users in POST_VOTES_REF of the post
        POST_VOTES_REF.child(id).observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            USER_VOTES_REF.child(userId).child(self.id).observe(.childAdded, with: { (snapshot) in

                //removing post from notifications
                guard let notificationId = snapshot.value as? String else {return}
                NOTIFICATIONS_REF.child(self.userId).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    POST_VOTES_REF.child(self.id).removeValue()
                    USER_VOTES_REF.child(userId).child(self.id).removeValue()
                })
            })
        }

        POST_DOWNVOTES_REF.child(id).observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            USER_DOWNVOTES_REF.child(userId).child(self.id).observe(.childAdded, with: { (snapshot) in

                //removing post from notifications
                guard let notificationId = snapshot.value as? String else {return}
                NOTIFICATIONS_REF.child(self.userId).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    POST_DOWNVOTES_REF.child(self.id).removeValue()
                    USER_DOWNVOTES_REF.child(userId).child(self.id).removeValue()
                })
            })
        }

        //removing from hashtagPostsRef
        let words = caption.components(separatedBy: .whitespacesAndNewlines)

        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .symbols)
                HASHTAG_POST_REF.child(word).child(self.id).removeValue()
            }
        }

        COMMENT_REF.child(self.id).removeValue()

        POSTS_REF.child(self.id).removeValue()
    }
}
