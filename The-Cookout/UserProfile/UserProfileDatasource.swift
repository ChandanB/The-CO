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
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [UserProfilePhotoCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return posts[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return posts.count
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
}