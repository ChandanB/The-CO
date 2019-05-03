//
//  Firebase Utils.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/16/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

extension Auth {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
        
    }
    
    func signUp(bio: String, name: String, username: String, email: String, password: String, image: UIImage?, completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, err) in
            if let err = err {
                print("Failed to create user:", err)
                completion(err)
                return
            }
            guard let uid = user?.user.uid else { return }
            if let image = image {
                Storage.storage().uploadUserProfileImage(image: image, completion: { (profileImageUrl) in
                    self.uploadUser(withUID: uid, bio: bio, name: name, username: username, email: email, profileImageUrl: profileImageUrl) {
                        completion(nil)
                    }
                })
            } else {
                self.uploadUser(withUID: uid, bio: bio, name: name, username: username, email: email) {
                    completion(nil)
                }
            }
        })
    }
    
    private func uploadUser(withUID uid: String, bio: String, name: String, username: String, email: String, profileImageUrl: String? = nil, completion: @escaping (() -> ())) {
        var dictionaryValues = ["name": name, "email": email, "username": username, "username_lowercase": username.lowercased(), "bio": bio]
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        
        let values = [uid: dictionaryValues]
        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to upload user to database:", err)
                return
            }
            completion()
        })
    }
    
    static func setUserInfomation(bio: String, name: String, profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        
        let dictionaryValues = ["name": name, "email": email, "username": username, "username_lowercase": username.lowercased(), "bio": bio, "profileImageUrl": profileImageUrl]
        let values = [uid: dictionaryValues]
        usersReference.setValue(values)
        
        onSuccess()
    }
    
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        API.database.currentUser?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            }else {
                
                let uid = API.database.currentUser?.uid
                
                let storageRef = Storage.storage().reference(forURL: Configuration.storageRoofRef).child("profile_image").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        guard let downloadUrl = url else { return }
                        let profileImageUrl = downloadUrl.absoluteString
                        
                        self.updateDatabase(profileImageUrl: profileImageUrl, username: username, email: email, onSuccess: onSuccess, onError: onError)
                        
                    })
                })
            }
        })
        
    }
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
        
        API.database.refCurrentUser?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
    }
    
    func logout(onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
    
}


extension Storage {
    
    fileprivate func uploadUserProfileImage(image: UIImage, completion: @escaping (String) -> ()) {
        guard let uploadData = image.jpegData(compressionQuality: 1) else { return } //changed from 0.3
        
        let storageRef = Storage.storage().reference().child("profile_images").child(NSUUID().uuidString)
        
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to upload profile image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to obtain download url for profile image:", err)
                    return
                }
                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                completion(profileImageUrl)
            })
        })
    }
    
    fileprivate func uploadPostImage(image: UIImage, filename: String, completion: @escaping (String) -> ()) {
        guard let uploadData = image.jpegData(compressionQuality: 1) else { return } //changed from 0.5
        
        let storageRef = Storage.storage().reference().child("post_images").child(filename)
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to upload post image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to obtain download url for post image:", err)
                    return
                }
                guard let postImageUrl = downloadURL?.absoluteString else { return }
                completion(postImageUrl)
            })
        })
    }
}


// MARK: - User Functions
extension Database {
    
    //MARK: Users
    func fetchUser(withUID uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary as [String : AnyObject])
            completion(user)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }
    
    func fetchCurrentUser(completion: @escaping (User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary as [String : AnyObject])
            completion(user)
        }
    }
    
    func fetchAllUsers(includeCurrentUser: Bool = true, completion: @escaping ([User]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var users = [User]()
            
            dictionaries.forEach({ (key, value) in
                if !includeCurrentUser, key == Auth.auth().currentUser?.uid {
                    completion([])
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary as [String : AnyObject])
                users.append(user)
            })
            
            users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            completion(users)
            
        }) { (err) in
            print("Failed to fetch all users from database:", (err))
            cancel?(err)
        }
    }
    
    func fetchUserByUsername(uid: String, username: String, completion: @escaping (User) -> Void) {
        Database.database().reference().child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .childAdded) { (snapshot) in
            print(snapshot)
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: snapshot.key, dictionary: userDictionary as [String : AnyObject])
            completion(user)
        }
    }
    
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        Database.database().reference().child("users").queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in
            
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                guard let userDictionary = child.value as? [String: Any] else { return }
                let user = User(uid: snapshot.key, dictionary: userDictionary as [String : AnyObject])
                completion(user)
            })
        }
    }
    
    func isFollowingUser(withUID uid: String, completion: @escaping (Bool) -> (), withCancel cancel: ((Error) -> ())?) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("following").child(currentLoggedInUserId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let isFollowing = snapshot.value as? Bool, isFollowing == true {
                completion(true)
            } else {
                completion(false)
            }
            
        }) { (err) in
            print("Failed to check if following:", err)
            cancel?(err)
        }
    }
    
    func fetchFollowers(userId: String, completion: @escaping (User) -> Void) {
        Database.database().reference().child("followers").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let followersDictionary = snapshot.value as? [String: Any] else { return }
            followersDictionary.forEach({ (key, value) in
                self.fetchUser(withUID: key, completion: { (user) in
                    completion(user)
                })
            })
        }
    }
    
    func fetchFollowing(userId: String, completion: @escaping (User) -> Void) {
        Database.database().reference().child("following").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let followingDictionary = snapshot.value as? [String: Any] else { return }
            followingDictionary.forEach({ (key, value) in
                self.fetchUser(withUID: key, completion: { (user) in
                    completion(user)
                })
            })
        }
    }
    
    func followUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: true]
        Database.database().reference().child("following").child(currentLoggedInUserId).updateChildValues(values) { (err, ref) in
            if let err = err {
                completion(err)
                return
            }
            
            let values = [currentLoggedInUserId: true]
            Database.database().reference().child("followers").child(uid).updateChildValues(values) { (err, ref) in
                if let err = err {
                    completion(err)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func unfollowUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("following").child(currentLoggedInUserId).child(uid).removeValue { (err, _) in
            if let err = err {
                print("Failed to remove user from following:", err)
                completion(err)
                return
            }
            
            Database.database().reference().child("followers").child(uid).child(currentLoggedInUserId).removeValue(completionBlock: { (err, _) in
                if let err = err {
                    print("Failed to remove user from followers:", err)
                    completion(err)
                    return
                }
                completion(nil)
            })
        }
    }
    
    
    //MARK: Posts
    func createImagePost(withImage image: UIImage, caption: String, user: User,  onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let userPostRef = Database.database().reference().child("posts").child(user.uid).childByAutoId()
        guard let postId = userPostRef.key else { return }
        
        print(user.uid)
        Storage.storage().uploadPostImage(image: image, filename: postId) { (postImageUrl) in
            
            let values = ["imageUrl": postImageUrl,
                          "caption": caption,
                          "imageWidth": image.size.width,
                          "imageHeight": image.size.height,
                          "creationDate": Date().timeIntervalSince1970,
                          "id": postId,
                          "hasImage": true,
                          "hasText": true] as [String : Any]
            
            userPostRef.updateChildValues(values) { (err, ref) in
                if let error = err {
                    print("Failed to save post to database", error)
                    onError(error.localizedDescription)
                    return
                }
                onSuccess()
            }
        }
    }
    
    func createPost(withCaption caption: String, user: User,  onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        let userPostRef = Database.database().reference().child("posts").child(user.uid).childByAutoId()
        guard let postId = userPostRef.key else { return }
        
        let values = ["caption": caption,
                      "creationDate": Date().timeIntervalSince1970,
                      "hasText": true,
                      "hasImage": false,
                      "id": postId] as [String : Any]
        
        print(user.uid)
        userPostRef.updateChildValues(values) { (err, ref) in
            if let error = err {
                print("Failed to save post to database", error)
                onError(error.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func fetchPost(withUID uid: String, postId: String, completion: @escaping (Post) -> (), withCancel cancel: ((Error) -> ())? = nil) {
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("posts").child(uid).child(postId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let postDictionary = snapshot.value as? [String: Any] else { return }
            
            Database.database().fetchUser(withUID: uid, completion: { (user) in
                var post = Post(user: user, dictionary: postDictionary as [String : AnyObject])
                post.id = postId
                
                //check reposts
                Database.database().reference().child("reposts").child(postId).child(currentLoggedInUser).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.repostedByCurrentUser = true
                    } else {
                        post.repostedByCurrentUser = false
                    }
                    
                    Database.database().numberOfRepostsForPost(withPostId: postId, completion: { (count) in
                        post.repostCount = count
                        completion(post)
                    })
                }, withCancel: { (err) in
                    print("Failed to fetch repost info for post:", err)
                    cancel?(err)
                })
            })
        })
    }
    
    func fetchAllPosts(withUID uid: String, completion: @escaping ([Post]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var posts = [Post]()
            
            dictionaries.forEach({ (postId, value) in
                Database.database().fetchPost(withUID: uid, postId: postId, completion: { (post) in
                    posts.append(post)
                    
                    if posts.count == dictionaries.count {
                        completion(posts)
                    }
                })
            })
            
        }) { (err) in
            print("Failed to fetch posts:", err)
            cancel?(err)
        }
    }
    
    func queryPosts(forUser user: User, posts: [Post], completion: @escaping ([Post]) -> Void) {
        
        var posts = posts
        var limit: UInt = 4
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.last != nil {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            limit = 10
        }
        
        query.queryLimited(toLast: limit).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([])
                return
            }
            
            allObjects.reverse()
            
            if posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                
                posts.append(post)
                posts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                
                completion(posts)
            })
        }
    }
    
    func queryGrid(forUser user: User, posts: [Post], finishedPaging: Bool, completion: @escaping ([Post], Bool) -> Void) {
        
        var isFinished = false
        var posts = posts
        var limit: UInt = 9
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.last != nil {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            limit = 10
        }
        
        query.queryLimited(toLast: limit).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([], true)
                return
            }
            
            allObjects.reverse()
            
            if !finishedPaging {
                if allObjects.count < limit {
                    isFinished = true
                }
            } else {
                if allObjects.count > limit {
                    isFinished = false
                }
            }
            
            if posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                
                if post.hasImage {
                    posts.append(post)
                    posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                }
                
                completion(posts, isFinished)
            })
        }
    }
    
    func queryList(forUser user: User, posts: [Post], finishedPaging: Bool, completion: @escaping ([Post], Bool) -> Void) {
        
        var isFinished = false
        var posts = posts
        var limit: UInt = 10
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.last != nil {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            limit = 12
        }
        
        query.queryLimited(toLast: limit).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                completion([], true)
                return
            }
            
            allObjects.reverse()
            
            if !finishedPaging {
                if allObjects.count < limit {
                    isFinished = true
                }
            } else {
                if allObjects.count > limit {
                    isFinished = false
                }
            }
            
            if posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                
                if !post.hasImage {
                    posts.append(post)
                    posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                }
                
                completion(posts, isFinished)
            })
        }
    }
    
    func fetchTopPosts(forUser user: User, completion: @escaping (Post) -> Void) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.queryOrdered(byChild: "overallVoteCount").observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post(user: user, dictionary: dict as [String : AnyObject])
                    completion(post)
                }
            })
        }
    }

    
    func deletePost(withUID uid: String, postId: String, completion: ((Error?) -> ())? = nil) {
        Database.database().reference().child("posts").child(uid).child(postId).removeValue { (err, _) in
            if let err = err {
                print("Failed to delete post:", err)
                completion?(err)
                return
            }
            
            Database.database().reference().child("comments").child(postId).removeValue(completionBlock: { (err, _) in
                if let err = err {
                    print("Failed to delete comments on post:", err)
                    completion?(err)
                    return
                }
                
                Database.database().reference().child("reposts").child(postId).removeValue(completionBlock: { (err, _) in
                    if let err = err {
                        print("Failed to delete reposts on post:", err)
                        completion?(err)
                        return
                    }
                    
                    Storage.storage().reference().child("post_images").child(postId).delete(completion: { (err) in
                        if let err = err {
                            print("Failed to delete post image from storage:", err)
                            completion?(err)
                            return
                        }
                    })
                    
                    completion?(nil)
                })
            })
        }
    }
    
    func addCommentToPost(withId postId: String, text: String, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["text": text, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        
        let commentsRef = Database.database().reference().child("comments").child(postId).childByAutoId()
        commentsRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to add comment:", err)
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func fetchCommentsForPost(withId postId: String, completion: @escaping ([Comment]) -> (), withCancel cancel: ((Error) -> ())?) {
        let commentsReference = Database.database().reference().child("comments").child(postId)
        
        commentsReference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var comments = [Comment]()
            
            dictionaries.forEach({ (key, value) in
                guard let commentDictionary = value as? [String: Any] else { return }
                guard let uid = commentDictionary["uid"] as? String else { return }
                
                Database.database().fetchUser(withUID: uid) { (user) in
                    let comment = Comment(user: user, dictionary: commentDictionary)
                    comments.append(comment)
                    
                    if comments.count == dictionaries.count {
                        comments.sort(by: { (comment1, comment2) -> Bool in
                            return comment1.creationDate.compare(comment2.creationDate) == .orderedAscending
                        })
                        completion(comments)
                    }
                }
            })
            
        }) { (err) in
            print("Failed to fetch comments:", err)
            cancel?(err)
        }
    }
    
    //MARK: Utilities
    
    func numberOfPostsForUser(withUID uid: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("posts").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
    
    func numberOfFollowersForUser(withUID uid: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("followers").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
    
    func numberOfFollowingForUser(withUID uid: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
    
    func numberOfRepostsForPost(withPostId postId: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("reposts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
    
    func overallVoteCountForPost(withPostId postId: String, completion: @escaping (Int) -> ()) {
        Database.database().reference().child("overallVoteCount").child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }
    
}
