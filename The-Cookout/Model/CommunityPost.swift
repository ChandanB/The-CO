//
//  CommunityPost.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class CommunityPost: Post {
    let communityName: String

    init(id: String, user: User, dictionary: [String: AnyObject], communityName: String) {
        self.communityName = communityName
        super.init(id: id, user: user, dictionary: dictionary)

        self.contentType = .community
    }
}
