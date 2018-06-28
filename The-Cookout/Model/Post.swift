//
//  Post.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

struct Post {
    var id: String?
    
    let user: User
    
    let caption: String
    var hasText: String
    var hasImage: String
    let imageUrl: String
    let videoUrl: String
    
    
    let votes: NSNumber
    let timestamp: NSNumber
    let imageWidth: NSNumber
    let imageHeight: NSNumber
    
    let creationDate: Date
    
    var likeCount = 0
    var hasLiked = false

    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        self.votes = dictionary["votes"] as? NSNumber ?? 0
        self.caption = dictionary["caption"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.videoUrl = dictionary["videoUrl"] as? String ?? ""
        self.hasText = dictionary["hasText"] as? String ?? "false"
        self.hasImage = dictionary["hasImage"] as? String ?? "false"
        self.timestamp = dictionary["timestamp"] as? NSNumber ?? 0
        self.imageWidth = dictionary["imageWidth"] as? NSNumber ?? 0
        self.imageHeight = dictionary["imageHeight"] as? NSNumber ?? 0
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
