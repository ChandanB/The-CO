//
//  ProfileDatasource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class ProfileDatasource: Datasource {
    
    var gridArray = [Post]()
    var listArray = [Post]()
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [UserProfileHeader.self]
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [UserProfilePhotoCell.self, PostCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        if indexPath.section == 1 {
           return gridArray[indexPath.item]
        } else {
            return listArray[indexPath.item]
        }
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        if section == 1 {
            return gridArray.count
        } else {
            return listArray.count
        }
    }
    
    override func numberOfSections() -> Int {
        return 2
    }
    
}
