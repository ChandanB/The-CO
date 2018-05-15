//
//  HomeDatasourceController+NavBar.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import Kingfisher

extension HomeDatasourceController {
    
    func fetchUserFeed() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let ref = Database.database().reference().child("users").child(uid)
        
        // Gets UserId and fetch if user added
        ref.child("recommended").observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            self.fetchUsers(userId)
        }, withCancel: nil)
        
        ref.child("recommended").observe(.childRemoved, with: { (snapshot) in
            let userId = snapshot.key
            self.deleteUsers(userId)
        }, withCancel: nil)
        
    }
    
    func refreshUserFeed() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        let myRef = Database.database().reference().child("users").child(uid)
        
        myRef.child("recommended").observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            let usersReference = ref.child("users").child(userId)
            
            // Add users to array
            usersReference.queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
                
                let userDictionary = snapshot.value as? [String: AnyObject]
                let user = User(dictionary: userDictionary!)
                self.homeDatasource.users.insert(user, at: 0)
                
                DispatchQueue.main.async {
                 //   self.datasource = self.homeDatasource
                    self.refresher.endRefreshing()
                    self.collectionView?.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    func fetchPostFeed() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(uid)
        let postsRef = ref.child("following").child("posts")
        
        // Gets PostId and fetch if child added
        postsRef.observe(.childAdded, with: { (snapshot) in
            let postId = snapshot.key
            self.fetchPosts(postId)
        }, withCancel: nil)
        
        postsRef.observe(.childRemoved, with: { (snapshot) in
            let postId = snapshot.key
            self.deletePosts(postId)
        }, withCancel: nil)
    }
    
    fileprivate func fetchUsers(_ userId: String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(userId)
        
        usersReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String: AnyObject] {
                self.homeDatasource.users.append(User(dictionary: userDictionary))
            }
            
            DispatchQueue.main.async {
                self.datasource = self.homeDatasource
                self.collectionView?.reloadData()
            }
        }, withCancel: nil)
    }
    
    fileprivate func fetchPosts(_ postId: String) {
        let ref = Database.database().reference()
        let postsReference = ref.child("posts").child(postId)
        // Add posts to array
        postsReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let postDictionary = snapshot.value as? [String: AnyObject] {
                self.homeDatasource.posts.append(Post(dictionary: postDictionary))
            }
            
            DispatchQueue.main.async {
                self.datasource = self.homeDatasource
                self.collectionView?.reloadData()
            }
        }, withCancel: nil)
    }
    
    fileprivate func deletePosts(_ postId: String) {
        let ref = Database.database().reference()
        let postsReference = ref.child("posts").child(postId)
        
        // Remove posts from array
        postsReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let postDictionary = snapshot.value as? [String: AnyObject] {
                let post = Post(dictionary: postDictionary)
           //     self.homeDatasource.posts.remove(at: post)
                self.datasource = self.homeDatasource
            }
        }, withCancel: nil)
    }
    
    fileprivate func deleteUsers(_ userId: String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(userId)
        
        // Remove users from array
        usersReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: userDictionary)
           //     self.homeDatasource.users.remove(at: user)
                self.datasource = self.homeDatasource
            }
        }, withCancel: nil)
    }
    
    func fetchImage(with imageUrl: String, completion: @escaping (UIImage?) -> Void) {
        // Check if cache is existing.
        if checkImageCache(with: imageUrl) {
            fetchImageFromCache(with: imageUrl, completion: { (image: Image?) in
                completion(image)
            })
            return
        }
        
        // Download image from url.
        download(from: imageUrl) { (image: Image?) in
            if let image = image {
                // Save image to cache
                self.saveImageToDisk(with: image, key: imageUrl)
                completion(image)
                
                return
            }
            completion(nil)
        }
    }
    
    private func checkImageCache(with key: String) -> Bool {
        return ImageCache.default.imageCachedType(forKey: key).cached
    }
    
    private func fetchImageFromCache(with key: String, completion: @escaping (Image?) -> Void) {
        ImageCache.default.retrieveImage(forKey: key, options: nil) {
            image, cacheType in
            completion(image)
        }
    }
    
    private func download(from imageUrl: String, completion: @escaping (Image?) -> Void) {
        ImageDownloader.default.downloadImage(with: URL(string: imageUrl)!, options: [], progressBlock: nil) {
            (image, error, url, data) in
            completion(image)
        }
    }
    
    private func saveImageToDisk(with image: Image, key: String) {
        ImageCache.default.store(image, forKey: key)
    }
    
}
