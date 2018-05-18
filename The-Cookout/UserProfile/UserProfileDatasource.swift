//
//  UserProfileDatasource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/15/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class UserProfileDataSource: Datasource {
    
    var posts = [Post]()
    var users = [User]()
    
//    override func headerClasses() -> [DatasourceCell.Type]? {
//        return [UserProfileHeader.self]
//    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [UserProfileCell.self, UserProfilePhotoCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        
        if indexPath.section == 0 {
            return users[indexPath.item]
        }
        
        return posts[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        
        if section == 0 {
            return users.count
        }
        
        return posts.count
    }
    
    override func numberOfSections() -> Int {
        return 2
    }
    
}
