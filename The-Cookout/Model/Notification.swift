//
//  Notification.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/6/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import Foundation

class NotificationModel {

    enum NotificationType: Int, Printable {

        case Like
        case Comment
        case Follow
        case CommentMention
        case PostMention

        var description: String {
            switch self {
            case .Like: return " liked your post"
            case .Comment: return " commented on your post"
            case .Follow: return " started following you"
            case .CommentMention: return " mentioned you in a comment"
            case .PostMention: return " mentioned you in a post"
            }
        }

        init(index: Int) {
            switch index {
            case 0: self = .Like
            case 1: self = .Comment
            case 2: self = .Follow
            case 3: self = .CommentMention
            case 4: self = .PostMention
            default: self = .Like
            }
        }
    }

    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User!
    var type: Int?
    var notificationType: NotificationType!
    var commentId: String?
    var commentText: String?
    var didCheck = false

    init(user: User, post: Post? = nil, dictionary: Dictionary<String, AnyObject>) {

        self.user = user

        if let post = post {
            self.post = post
        }

        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }

        if let type = dictionary["type"] as? Int {
            self.notificationType = NotificationType(index: type)
        }

        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }

        if let postId = dictionary["postId"] as? String {
            self.postId = postId
        }

        if let commentId = dictionary["commentId"] as? String {
            self.commentId = commentId
        }

        if let checked = dictionary["checked"] as? Int {
            if checked == 0 {
                self.didCheck = false
            } else {
                self.didCheck = true
            }
        }
    }
}
