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
    let user: User
    
    var caption: String
    var imageUrl: String
    var videoUrl: String
    
    var hasText: Bool
    let hasImage: Bool
    
    var hasLiked: Bool
    var likeCount: Int
    var likes: Dictionary<String, Any>
    
    let creationDate: Date
    let timestamp: NSNumber
    
    var ratio: CGFloat
    let imageWidth: NSNumber
    let imageHeight: NSNumber
    
    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.videoUrl = dictionary["videoUrl"] as? String ?? ""
        
        self.hasText = dictionary["hasText"] as? Bool ?? false
        self.hasImage = dictionary["hasImage"] as? Bool ?? false
        
        self.hasLiked = dictionary["hasLiked"] as? Bool ?? false
        self.likeCount = dictionary["likeCount"] as? Int ?? 0
        self.likes = dictionary["likes"] as? Dictionary ?? ["": 0]
        
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
        post.likeCount = dict["likeCount"] as? Int ?? 0
        post.likes = dict["likes"] as? Dictionary<String, Any> ?? ["": 0]
        post.ratio = dict["ratio"] as? CGFloat ?? 0
        if let currentUserId = Auth.auth().currentUser?.uid {
            post.hasLiked = post.likes[currentUserId] != nil
        }
        return post
    }
}
