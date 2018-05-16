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

extension HomeController {
    
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user)
        }
    }
    
    fileprivate func fetchPostsWithUser(_ user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                self.homeDatasource.posts.append(post)
            })
            self.collectionView?.reloadData()
        }
    }
    
    
    fileprivate func fetchUsers(_ userId: String) {
        let ref = Database.database().reference().child("users").child(userId)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(uid: userId, dictionary: dictionary)
                self.homeDatasource.users.append(user)
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
}
