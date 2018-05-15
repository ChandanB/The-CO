//
//  Post.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

struct Post {
    let fromId: String
    let timestamp: NSNumber
    let text: String
    let profileImageUrl: String
    let imageUrl: String
    let videoUrl: String
    let imageWidth: NSNumber
    let imageHeight: NSNumber
    let likes: String
    let dislikes: String
    let username: String
    let name: String
    
    init(dictionary: [String: AnyObject]) {
        self.text = dictionary["text"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.likes = dictionary["likes"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.videoUrl = dictionary["videoUrl"] as? String ?? ""
        self.dislikes = dictionary["dislikes"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? NSNumber ?? 0
        self.imageWidth = dictionary["imageWidth"] as? NSNumber ?? 0
        self.imageHeight = dictionary["imageHeight"] as? NSNumber ?? 0
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
