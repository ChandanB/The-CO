//
//  Api.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation

struct Api {
    static var user = UserApi()
    static var post = PostApi()
    static var comment = CommentApi()
    static var postComment = PostCommentApi()
    static var myPosts = MyPostsApi()
    static var follow = FollowApi()
    static var feed = FeedApi()
    static var hashTag = HashTagApi()
}
