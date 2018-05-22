//
//  UserAPI.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation

import FirebaseDatabase
import FirebaseAuth

class UserApi {
    var usersRef = Database.database().reference().child("users")
    
    func observeUserByUsername(uid: String, username: String, completion: @escaping (User) -> Void) {
        usersRef.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            snapshot in
            print(snapshot)
            if let dict = snapshot.value as? [String: Any] {
                let user = User(uid: snapshot.key, dictionary: dict as [String : AnyObject])
                completion(user)
            }
        })
    }
   
    
    func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
        usersRef.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User(uid: uid, dictionary: dict as [String : AnyObject])
                completion(user)
            }
        })
    }
    
    func observeCurrentUser(completion: @escaping (User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        usersRef.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User(uid: currentUser.uid, dictionary: dict as [String : AnyObject])
                completion(user)
            }
        })
    }
    
    func observeUsers(completion: @escaping (User) -> Void) {
        usersRef.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User(uid: snapshot.key, dictionary: dict as [String : AnyObject])
                completion(user)
            }
        })
    }
    
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        usersRef.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let user = User(uid: snapshot.key, dictionary: dict as [String : AnyObject])
                    completion(user)
                }
            })
        })
    }
    
    let currentUser = Auth.auth().currentUser
      
    var refCurrentUser: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return usersRef.child(currentUser.uid)
    }
}
