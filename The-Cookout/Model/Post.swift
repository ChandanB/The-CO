//
//  Post.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase

struct Post {
    var id: String?
    var userId: String?
    let user: User
    
    var caption: String
    var imageUrl: String
    var videoUrl: String
    
    var hasText: Bool
    let hasImage: Bool
    
    var repostedByCurrentUser: Bool = false
    var repostCount: Int = 0
    var reposts: Dictionary<String, Any>
    
    var upvotedByCurrentUser: Bool = false
    var upvoteCount: Int = 0
    var upvotes: Dictionary<String, Any>
    
    var downvotedByCurrentUser: Bool = false
    var downvoteCount: Int = 0
    var downvotes: Dictionary<String, Any>
    
    var overallVoteCount: Int = 0
    
    let creationDate: Date
    let timestamp: NSNumber
    
    var ratio: CGFloat
    let imageWidth: NSNumber
    let imageHeight: NSNumber
    
    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        self.id = dictionary["id"] as? String ?? ""
        self.userId = dictionary["userId"] as? String ?? ""
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.videoUrl = dictionary["videoUrl"] as? String ?? ""
        
        self.hasText = dictionary["hasText"] as? Bool ?? false
        self.hasImage = dictionary["hasImage"] as? Bool ?? false
        
        self.repostedByCurrentUser = dictionary["repostedByCurrentUser"] as? Bool ?? false
        self.repostCount = dictionary["repostCount"] as? Int ?? 0
        self.reposts = dictionary["reposts"] as? Dictionary ?? ["": 0]
        
        self.upvotedByCurrentUser = dictionary["upvotedByCurrentUser"] as? Bool ?? false
        self.upvoteCount = dictionary["upvoteCount"] as? Int ?? 0
        self.upvotes = dictionary["upvotes"] as? Dictionary ?? ["": 0]
        
        self.downvotedByCurrentUser = dictionary["downvotedByCurrentUser"] as? Bool ?? false
        self.downvoteCount = dictionary["downvoteCount"] as? Int ?? 0
        self.downvotes = dictionary["downvotes"] as? Dictionary ?? ["": 0]
        
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
    static func transformPostPhoto(user: User, dict: [String: Any], key: String) -> Post {
        var post = Post(user: user, dictionary: dict as [String : AnyObject])
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
}
