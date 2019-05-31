////
////  SPAPI.swift
////  The-Cookout
////
////  Created by Chandan Brown on 4/29/19.
////  Copyright © 2019 Chandan B. All rights reserved.
////
//
//import Firebase
//
//
//public enum Users: NRDatabaseTarget {
//    
//    // MARK: - Base Reference
//    public var baseReference: DatabaseReference {
//        return Database.database().reference()
//    }
//    
//    // MARK: - Session
//    case createSession(username: String)
//    
//    // MARK: - Users
//    case createUser(email: String, name: String, username: String, bio: String, profileImageUrl: String)
//    case deleteUser(id: String)
//    case getUser(id: String)
//    case fetchAllUsers
//    
//    // MARK: - Posts
//    case createPost(mediaAssetURL: String, mediaThumbURL: String, isVideo: Bool)
//    case fetchPost(id: String)
//    case fetchAllPosts
//    case deletePost(id: String)
//    
//    // MARK: - Stories
//    case fetchAllStories
//    
//    public var path: String {
//        
//        switch self {
//            
//        case .createSession:
//            return "sessions"
//            
//        case .fetchAllUsers:
//            return "users"
//
//        case .fetchAllStories:
//            return "stories"
//
//        case .createPost, .fetchAllPosts:
//            return "posts"
//            
//        case .fetchPost(let id), .deletePost(let id):
//            return "posts/\(id)"
//            
//        case .getUser(let id), .deleteUser(let id):
//            return id
//            
//        case .createUser:
//            return uniqueID()
//        }
//    }
//    
//    public var task: NRDatabaseTask {
//        
//        switch self {
//        case .getUser, .fetchPost, .fetchAllUsers:
//            return .observeOnce(.value)
//            
//        case .fetchAllPosts, .fetchAllStories:
//            return .observeOnce(.childAdded)
//        
//        case .deleteUser, .deletePost:
//            return .removeValue
//     
//        case .createUser(let email, let name, let username, let bio, let profileImageUrl):
//            return .setValue(["name": name, "email": email, "username": username, "bio": bio, "profileImageUrl": profileImageUrl])
//        
//        case .createSession(let username):
//        return .setValue(["username": username])
//        
//        case .createPost(let mediaAssetURL, let mediaThumbURL, let isVideo):
//        return .setValue(["media_asset_url": mediaAssetURL, "media_thumb_url": mediaThumbURL, "is_video": isVideo])
//    }
//    }
//    
//}
//
//
//// MARK: - Authorization
//extension Users {
//    
//    public var shouldAuthorize: Bool {
//        switch self {
//        case .createPost, .fetchAllStories:
//            return true
//        default:
//            return false
//        }
//    }
//    
//}
//
//
//// MARK: - Helpers
//private extension String {
//    var urlEscaped: String {
//        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
//    }
//    
//    var utf8Encoded: Data {
//        return self.data(using: .utf8)!
//    }
//}
//
