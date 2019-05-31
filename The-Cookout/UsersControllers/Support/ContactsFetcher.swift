//
//  ContactsFetcher.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Contacts
import Firebase

protocol UsersUpdatesDelegate: class {
  func users(updateDatasource users: [User])
  func users(handleAccessStatus: Bool)
}

class UsersFetcher: NSObject {
  
  weak var delegate: UsersUpdatesDelegate?
  
  func fetchUsers () {
    guard let uid = CURRENT_USER?.uid else {return}
    var users = [User]()
    Database.database().fetchFollowing(userId: uid) { (user) in
        self.delegate?.users(handleAccessStatus: true)
        users.append(user)
        localUserIDs.append(user.uid)
        self.delegate?.users(updateDatasource: users)
    }
  }
    
}
