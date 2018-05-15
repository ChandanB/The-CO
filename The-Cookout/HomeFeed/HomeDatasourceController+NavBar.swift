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
        let ref = Database.database().reference().child("users").child(uid).child("recommended")
        
        ref.observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            self.fetchUsers(userId)
        }
    }
    
    func fetchPostFeed() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let baseRef = Database.database().reference().child("users").child(uid)
        let ref = baseRef.child("following").child("posts")
        
        ref.observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            self.fetchPosts(postId)
        }
    }
    
    fileprivate func fetchUsers(_ userId: String) {
        let ref = Database.database().reference().child("users").child(userId)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.homeDatasource.users.append(User(dictionary: dictionary))
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    fileprivate func fetchPosts(_ postId: String) {
        let ref = Database.database().reference().child("posts").child(postId)
        // Add posts to array
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.homeDatasource.posts.append(Post(dictionary: dictionary))
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
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
