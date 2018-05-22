//
//  User.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

struct User {
    let uid: String
    let name: String
    let email: String
    let bio: String
    let username: String
    let profileImage: UIImage
    let profileImageUrl: String
    let bannerImageUrl: String
    var isFollowing = false
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        self.bio = dictionary["bio"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.bannerImageUrl = dictionary["bannerImageUrl"] as? String ?? ""
        self.profileImage = UIImage()
    }
}
