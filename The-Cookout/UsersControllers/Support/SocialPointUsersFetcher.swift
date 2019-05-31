//
//  SocialPointUsersFetcher.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol SocialPointUsersUpdatesDelegate: class {
    func socialPointUsers(shouldBeUpdatedTo users: [User])
}

public var shouldReFetchSocialPointUsers: Bool = false

class SocialPointUsersFetcher: NSObject {
    
    var users = [User]()
    
    weak var delegate: SocialPointUsersUpdatesDelegate?
    
    var userQuery: DatabaseQuery!
    var userHandle = [DatabaseHandle]()
    var group = DispatchGroup()
    
    fileprivate func clearObserversAndUsersIfNeeded() {
        self.users.removeAll()
        for handle in userHandle {
            USER_REF.removeObserver(withHandle: handle)
        }
    }
    
    func fetchSocialPointUsers(asynchronously: Bool) {
        clearObserversAndUsersIfNeeded()

        if asynchronously {
            fetchAsynchronously()
        } else {
            fetchSynchronously()
        }
    }
    
    fileprivate func fetchSynchronously() {
        var preparedUserIDs = [String]()
        
        for id in localUserIDs {
            preparedUserIDs.append(id)
            self.group.enter()
            print("entering group")
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            print("Contacts load finished SocialPoint")
            self.delegate?.socialPointUsers(shouldBeUpdatedTo: self.users)
        })
        
        for id in preparedUserIDs {
            fetchAndObserveUser(for: id, asynchronously: false)
        }
    }
    
    fileprivate func fetchAsynchronously() {
        for id in localUserIDs {
            fetchAndObserveUser(for: id, asynchronously: true)
        }
    }

    
    fileprivate func fetchAndObserveUser(for preparedID: String, asynchronously: Bool) {
        
        userQuery = USER_REF.queryOrdered(byChild: "uid")
        let databaseHandle = DatabaseHandle()
        userHandle.insert(databaseHandle, at: 0 )
        
        userHandle[0] = userQuery.queryEqual(toValue: preparedID).observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                guard let children = snapshot.children.allObjects as? [DataSnapshot] else { return }
                for child in children {
                    guard var dictionary = child.value as? [String: AnyObject] else { return }
                    dictionary.updateValue(child.key as AnyObject, forKey: "uid")
                    
                    let thumbnailURLString = User(uid: child.key, dictionary: dictionary).thumbnailPhotoURL
                    let thumbnailURL = URL(string: thumbnailURLString)
                    SDWebImagePrefetcher.shared.prefetchURLs([thumbnailURL!])
                    
                    if let index = self.users.firstIndex(where: { (user) -> Bool in
                        return user.uid == User(uid: user.uid, dictionary: dictionary).uid
                    }) {
                        self.users[index] = User(uid: child.key, dictionary: dictionary)
                    } else {
                        self.users.append(User(uid: child.key, dictionary: dictionary))
                    }
                    
                    self.users = self.sortUsers(users: self.users)
                    self.users = self.rearrangeUsers(users: self.users)
                    
                    if let index = self.users.firstIndex(where: { (user) -> Bool in
                        return user.uid == CURRENT_USER?.uid
                    }) {
                        self.users.remove(at: index)
                    }
                }
                
                if asynchronously {
                    self.delegate?.socialPointUsers(shouldBeUpdatedTo: self.users)
                }
            }
            
            if !asynchronously {
                self.group.leave()
                print("leaving group")
            }
            
        }, withCancel: { (error) in
            print("error")
        })
    }
    
    func rearrangeUsers(users: [User]) -> [User] { /* Moves Online users to the top  */
        var users = users
        guard users.count - 1 > 0 else { return users }
        for index in 0...users.count - 1 {
            if users[index].onlineStatus as? String == statusOnline {
                users = rearrange(array: users, fromIndex: index, toIndex: 0)
            }
        }
        return users
    }
    
    func sortUsers(users: [User]) -> [User] { /* Sort users by last online date  */
        return users.sorted(by: { (user1, user2) -> Bool in
            if let firstUserOnlineStatus = user1.onlineStatus as? TimeInterval , let secondUserOnlineStatus = user2.onlineStatus as? TimeInterval {
                return (firstUserOnlineStatus, user1.uid) > ( secondUserOnlineStatus, user2.uid)
            } else {
                return ( user1.uid) > (user2.uid) // sort
            }
        })
    }
}
