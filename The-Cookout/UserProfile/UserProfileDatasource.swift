//
//  UserProfileDatasource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/15/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class UserProfileDatasource: Datasource {
    
    var user: User?
    var gridData = [Post]()
    var listData = [Post]()
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [UserProfileCell.self]
    }

    override func cellClasses() -> [DatasourceCell.Type] {
        return [UserProfilePhotoCell.self, PostCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        if indexPath.section == 0 {
            return gridData[indexPath.item]
        }
        return listData[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        if section == 0 {
            return gridData.count
        }
         return listData.count
    }
    
    override func headerItem(_ section: Int) -> Any? {
        return user!
    }

    override func numberOfSections() -> Int {
        return 2
    }
    
}




