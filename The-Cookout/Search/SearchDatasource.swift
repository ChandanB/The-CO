//
//  SearchDatasource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/16/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class SearchDataSource: Datasource {
    
    var users = [User]()
    var filteredUsers = [User]()
    var topUsers = [User]()
    
    var vc: UserSearchController?
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [UserHeader.self]
    }
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [UserFooter.self]
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [UserSearchCell.self, UserSearchCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        
        if indexPath.section == 0 {
            return topUsers[indexPath.item]
        }
        
        return filteredUsers[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        
        if section == 0 {
            return topUsers.count
        }
        
        return filteredUsers.count
    }
    
    override func numberOfSections() -> Int {
        return 2
    }
    
}
