//
//  Comment.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/18/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let uid: String
    let user: User
    let creationDate: Date
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
