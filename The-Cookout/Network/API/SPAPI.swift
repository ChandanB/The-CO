//
//  Api.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import Firebase

struct API {
    static var database = SPDatabase()
}

//struct Api {
//    static var user = UserApi()
//    static var post = PostApi()
//    static var posts = PostsApi()
//    static var comment = CommentApi()
//    static var postComment = PostCommentApi()
//    static var myPosts = MyPostsApi()
//    static var follow = FollowApi()
//    static var hashTag = HashTagApi()
//}

//enum APIS {
//    case user(id: String)
//    case post(id: String)
//    case comment(id: String)
//    case postComment(id: String)
//    case myPosts(id: String)
//    case follow(id: String)
//    case posts(id: String)
//    case hashtag(id: String)
//}
//
//extension APIS {
//    public var task: Any  {
//        switch self {
//        case .user:
//            return UserApi()
//        case .post:
//            return PostApi()
//        case .comment:
//            return CommentApi()
//        case .postComment:
//            return PostCommentApi()
//        case .myPosts:
//            return MyPostsApi()
//        case .follow:
//            return FollowApi()
//        case .posts:
//            return PostsApi()
//        case .hashtag:
//            return HashTagApi()
//        }
//    }
//}
