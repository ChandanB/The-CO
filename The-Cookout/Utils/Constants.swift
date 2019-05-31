//
//  Constants.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import Firebase

// MARK: - Root References
let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()
let CURRENT_USER = Auth.auth().currentUser

// MARK: - Storage References
let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
let STORAGE_MESSAGE_IMAGES_REF = STORAGE_REF.child("message_images")
let STORAGE_MESSAGE_VIDEO_REF = STORAGE_REF.child("video_messages")
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")

// MARK: - Database References
let USER_REF = DB_REF.child("users")

let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")

let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")

let USER_FEED_REF = DB_REF.child("user-feed")

let USER_REPOSTS_REF = DB_REF.child("user-reposts")
let POST_REPOSTS_REF = DB_REF.child("post-reposts")

let USER_VOTES_REF = DB_REF.child("user-votes")
let POST_VOTES_REF = DB_REF.child("post-votes")

let USER_DOWNVOTES_REF = DB_REF.child("user-downvotes")
let POST_DOWNVOTES_REF = DB_REF.child("post-donwvotes")

let COMMENT_REF = DB_REF.child("comments")

let NOTIFICATIONS_REF = DB_REF.child("notifications")

let MESSAGES_REF = DB_REF.child("messages")
let USER_MESSAGES_REF = DB_REF.child("user-messages")
let USER_MESSAGE_NOTIFICATIONS_REF = DB_REF.child("user-message-notifications")

let HASHTAG_POST_REF = DB_REF.child("hashtag-post")

// MARK: - Decoding Values
let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
let COMMENT_MENTION_INT_VALUE = 3
let POST_MENTION_INT_VALUE = 4

