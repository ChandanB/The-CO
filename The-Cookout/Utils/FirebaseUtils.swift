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
        Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })

    }

    func signUp(bio: String, name: String, username: String, email: String, password: String, image: UIImage?, completion: @escaping (Error?) -> Void) {
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

    private func uploadUser(withUID uid: String, bio: String, name: String, username: String, email: String, profileImageUrl: String? = nil, completion: @escaping (() -> Void)) {

        var dictionaryValues = ["name": name, "email": email, "username": username, "username_lowercase": username.lowercased(), "bio": bio]

        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
            dictionaryValues["thumbnailPhotoURL"] = profileImageUrl
        }

        let values = [uid: dictionaryValues]
        USERS_REF.updateChildValues(values, withCompletionBlock: { (err, _) in
            if let err = err {
                print("Failed to upload user to database:", err)
                return
            }
            completion()
        })

    }

    static func setUserInfomation(bio: String, name: String, profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let dictionaryValues = ["name": name, "email": email, "username": username, "username_lowercase": username.lowercased(), "bio": bio, "profileImageUrl": profileImageUrl]
        let values = [uid: dictionaryValues]
        USERS_REF.setValue(values)

        onSuccess()
    }

    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {

        CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {

                let uid = CURRENT_USER?.uid

                let storageRef = Storage.storage().reference(forURL: Configuration.storageRoofRef).child("profile_images").child(uid!)

                storageRef.putData(imageData, metadata: nil, completion: { (_, error) in
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

        API.database.refCurrentUser?.updateChildValues(dict, withCompletionBlock: { (error, _) in
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

    fileprivate func uploadUserProfileImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let uploadData = image.jpegData(compressionQuality: 1) else { return } //changed from 0.3

        let storageRef = STORAGE_PROFILE_IMAGES_REF.child(NSUUID().uuidString)

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

    fileprivate func uploadPostImage(image: UIImage, filename: String, completion: @escaping (String) -> Void) {
        guard let uploadData = image.jpegData(compressionQuality: 1) else { return } //changed from 0.5

        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)

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

    // MARK: Users
    func fetchUser(withUID uid: String, completion: @escaping (User) -> Void) {
        USERS_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary as [String: AnyObject])
            completion(user)
        }) { (err) in
            print("Failed to fetch user from database:", err)
        }
    }

    func fetchCurrentUser(completion: @escaping (User) -> Void) {
        guard let uid = CURRENT_USER?.uid else {return}

        USERS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary as [String: AnyObject])
            completion(user)
        }
    }

    func fetchAllUsers(includeCurrentUser: Bool = true, completion: @escaping ([User]) -> Void, withCancel cancel: ((Error) -> Void)?) {
        USERS_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            var users = [User]()

            dictionaries.forEach({ (key, value) in
                if !includeCurrentUser, key == CURRENT_USER?.uid {
                    completion([])
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary as [String: AnyObject])
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
        USERS_REF.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .childAdded) { (snapshot) in
            print(snapshot)
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: snapshot.key, dictionary: userDictionary as [String: AnyObject])
            completion(user)
        }
    }

    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        USERS_REF.queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in

            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                guard let userDictionary = child.value as? [String: Any] else { return }
                let user = User(uid: snapshot.key, dictionary: userDictionary as [String: AnyObject])
                completion(user)
            })
        }
    }

    func isFollowingUser(withUID uid: String, completion: @escaping (Bool) -> Void, withCancel cancel: ((Error) -> Void)?) {
        guard let currentLoggedInUserId = CURRENT_USER?.uid else { return }

        USER_FOLLOWING_REF.child(currentLoggedInUserId).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
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
        USER_FOLLOWER_REF.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let followersDictionary = snapshot.value as? [String: Any] else { return }
            followersDictionary.forEach({ (key, _) in
                self.fetchUser(withUID: key, completion: { (user) in
                    completion(user)
                })
            })
        }
    }

    func fetchFollowing(userId: String, completion: @escaping (User) -> Void) {
        USER_FOLLOWING_REF.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let followingDictionary = snapshot.value as? [String: Any] else { return }
            followingDictionary.forEach({ (key, _) in
                self.fetchUser(withUID: key, completion: { (user) in
                    completion(user)
                })
            })
        }
    }

    func fetchArrayOfFollowing(userId: String, completion: @escaping ([User]) -> Void) {
        USER_FOLLOWING_REF.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let followingDictionary = snapshot.value as? [String: Any] else { return }
            var followersArray = [User]()
            followingDictionary.forEach({ (key, _) in
                self.fetchUser(withUID: key, completion: { (user) in
                    followersArray.append(user)
                    completion(followersArray)
                })
            })
        }
    }

    func followUser(withUID uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentLoggedInUserId = CURRENT_USER?.uid else { return }

        let values = [uid: true]
        USER_FOLLOWING_REF.child(currentLoggedInUserId).updateChildValues(values) { (err, ref) in
            if let err = err {
                completion(err)
                return
            }

            let values = [currentLoggedInUserId: true]
            USER_FOLLOWER_REF.child(uid).updateChildValues(values) { (err, _) in
                if let err = err {
                    completion(err)
                    return
                }
                completion(nil)
            }
        }
    }

    func unfollowUser(withUID uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentLoggedInUserId = CURRENT_USER?.uid else { return }

        USER_FOLLOWING_REF.child(currentLoggedInUserId).child(uid).removeValue { (err, _) in
            if let err = err {
                print("Failed to remove user from following:", err)
                completion(err)
                return
            }

            USER_FOLLOWER_REF.child(uid).child(currentLoggedInUserId).removeValue(completionBlock: { (err, _) in
                if let err = err {
                    print("Failed to remove user from followers:", err)
                    completion(err)
                    return
                }
                completion(nil)
            })
        }
    }

    // MARK: Posts
    func createImagePost(withImage image: UIImage, caption: String, user: User, onSuccess: @escaping (String) -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let userPostRef = POSTS_REF.childByAutoId()

        guard let postId = POSTS_REF.key else {return}

        Storage.storage().uploadPostImage(image: image, filename: postId) { (postImageUrl) in

            let values = ["imageUrl": postImageUrl,
                          "caption": caption,
                          "imageWidth": image.size.width,
                          "imageHeight": image.size.height,
                          "creationDate": Date().timeIntervalSince1970,
                          "id": postId,
                          "hasImage": true,
                          "uid": user.uid,
                          "hasText": true] as [String: Any]

            userPostRef.updateChildValues(values) { (err, _) in
                if let error = err {
                    print("Failed to save post to database", error)
                    onError(error.localizedDescription)
                    return
                }
                print("Successfully saved post to database")
                onSuccess(postId)
            }
        }
    }

    func createPost(withCaption caption: String, user: User, onSuccess: @escaping (String) -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {

        let userPostRef = POSTS_REF.childByAutoId()
        guard let postId = userPostRef.key else { return }

        let values = ["caption": caption,
                      "creationDate": Date().timeIntervalSince1970,
                      "hasText": true,
                      "hasImage": false,
                      "uid": user.uid,
                      "postId": postId] as [String: Any]

        print(user.uid)
        userPostRef.updateChildValues(values) { (err, _) in
            if let error = err {
                print("Failed to save post to database", error)
                onError(error.localizedDescription)
                return
            }
            onSuccess(postId)
        }
    }

    func fetchPost(with postId: String, user: User, completion: @escaping ((Post?)->())) {
        var dictionary : [String:Any] = [:]
        var post : Post?
        var count = 0
        POSTS_REF.child(postId).observe(.childAdded, with: { (snapshot) in
            dictionary[snapshot.key] = snapshot.value
            post = Post(id: postId, user: user, dictionary: dictionary)
            count += 1
            if count == 5 {
                completion(post)
            }
        })
    }

    func fetchAllPosts(withUID uid: String, completion: @escaping ([Post]) -> Void, withCancel cancel: ((Error) -> Void)?) {
//        let ref = Database.database().reference().child("posts").child(uid)
//        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionaries = snapshot.value as? [String: Any] else {
//                completion([])
//                return
//            }
//            
//            var posts = [Post]()
//            
//            dictionaries.forEach({ (postId, value) in
//                Database.database().fetchPost(withUID: uid, postId: postId, completion: { (post) in
//                    posts.append(post)
//                    
//                    if posts.count == dictionaries.count {
//                        completion(posts)
//                    }
//                })
//            })
//            
//        }) { (err) in
//            print("Failed to fetch posts:", err)
//            cancel?(err)
//        }
    }

    func fetchPostsForUser(databaseRef ref: DatabaseReference, currentKey: String?, user: User, initialCount: UInt, furtherCount: UInt, lastPostId: @escaping ((DataSnapshot)->()), postFetched: @escaping ((Post)->())) {

        if currentKey != nil {
            ref.queryOrderedByKey().queryEnding(atValue: currentKey).queryLimited(toLast: furtherCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                guard let first = allObjects.first else {return}

                for object in allObjects {
                    let postId = object.key
                    if postId == currentKey {continue}
                    self.fetchPost(with: postId, user: user, completion: { (post) in
                        guard let post = post else {return}
                        postFetched(post)
                    })
                }
                lastPostId(first)
            }
        } else {
            ref.queryLimited(toLast: initialCount).observeSingleEvent(of: .value) { (snapshot) in
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                guard let first = allObjects.first else {return}

                for object in allObjects {
                    let postId = object.key
                    self.fetchPost(with: postId, user: user, completion: { (post) in
                        guard let post = post else {return}
                        postFetched(post)
                    })
                }
                lastPostId(first)
            }
        }
    }

    func queryGrid(forUser user: User, posts: [Post], finishedPaging: Bool, completion: @escaping ([Post], Bool) -> Void) {

        var isFinished = false
        var posts = posts
        var limit: UInt = 6
        let uid = user.uid
        let ref = POSTS_REF.child(uid)
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

            isFinished = false

//            if !finishedPaging {
//                if allObjects.count < limit {
//                    isFinished = true
//                }
//            } else {
//                if allObjects.count > limit {
//                    isFinished = false
//                }
//            }

            if posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }

            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let post = Post(id: user.uid, user: user, dictionary: dictionary as [String: AnyObject])

                if post.hasImage {
                    posts.append(post)
                    posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    completion(posts, isFinished)
                }
            })
        }
    }

    func queryList(forUser user: User, posts: [Post], finishedPaging: Bool, completion: @escaping ([Post], Bool) -> Void) {

        var isFinished = false
        var posts = posts
        var limit: UInt = 10
        let uid = user.uid
        let ref = POSTS_REF.child(uid)
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

            isFinished = false

//            if !finishedPaging {
//                if allObjects.count < limit {
//                    isFinished = true
//                }
//            } else {
//                if allObjects.count > limit {
//                    isFinished = false
//                }
//            }
//
            if posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }

            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let post = Post(id: user.uid,  user: user, dictionary: dictionary as [String: AnyObject])

                if !post.hasImage {
                    posts.append(post)
                    posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    completion(posts, isFinished)
                }
            })
        }
    }

    func fetchTopPosts(forUser user: User, completion: @escaping (Post) -> Void) {
        let ref = POSTS_REF.child(user.uid)

        ref.queryOrdered(byChild: "overallVoteCount").observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String: Any] {
                    let post = Post(id: user.uid, user: user, dictionary: dict as [String: AnyObject])
                    completion(post)
                }
            })
        }
    }

    func deletePost(withUID uid: String, postId: String, completion: ((Error?) -> Void)? = nil) {
        POSTS_REF.child(uid).child(postId).removeValue { (err, _) in
            if let err = err {
                print("Failed to delete post:", err)
                completion?(err)
                return
            }

            COMMENT_REF.child(postId).removeValue(completionBlock: { (err, _) in
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

    func addCommentToPost(withId postId: String, text: String, completion: @escaping (Error?) -> Void) {
        guard let uid = CURRENT_USER?.uid else { return }

        let values = ["text": text, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]

        let commentsRef = COMMENT_REF.child(postId).childByAutoId()
        commentsRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to add comment:", err)
                completion(err)
                return
            }
            completion(nil)
        }
    }

    func fetchCommentsForPost(withId postId: String, completion: @escaping ([Comment]) -> Void, withCancel cancel: ((Error) -> Void)?) {
        let commentsReference = COMMENT_REF.child(postId)

        commentsReference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            var comments = [Comment]()

            dictionaries.forEach({ (_, value) in
                guard let commentDictionary = value as? [String: Any] else { return }
                guard let uid = commentDictionary["uid"] as? String else { return }

                self.fetchUser(withUID: uid) { (user) in
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

    // MARK: Utilities

    func numberOfPostsForUser(withUID uid: String, completion: @escaping (Int) -> Void) {
        POSTS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }

    func numberOfFollowersForUser(withUID uid: String, completion: @escaping (Int) -> Void) {
        USER_FOLLOWER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }

    func numberOfFollowingForUser(withUID uid: String, completion: @escaping (Int) -> Void) {
        USER_FOLLOWING_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }

    func numberOfRepostsForPost(withPostId postId: String, completion: @escaping (Int) -> Void) {
        Database.database().reference().child("reposts").child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }

    func overallVoteCountForPost(withPostId postId: String, completion: @escaping (Int) -> Void) {
        Database.database().reference().child("overallVoteCount").child(postId).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionaries = snapshot.value as? [String: Any] {
                completion(dictionaries.count)
            } else {
                completion(0)
            }
        }
    }

}
