//
//  HomeDatasource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class HomeDataSource: Datasource {
    
    var users = [User]()
    var posts = [Post]()
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [UserHeader.self]
    }
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [UserFooter.self]
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [UserCell.self, PostCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        
        if indexPath.section == 1 {
            return posts[indexPath.item]
        }
        
        return users[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        
        if section == 1 {
            return posts.count
        }
        
        return users.count
    }
    
    override func numberOfSections() -> Int {
        return 2
    }
    
}
