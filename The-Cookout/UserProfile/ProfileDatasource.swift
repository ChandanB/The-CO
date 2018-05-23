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

    
    override func numberOfSections() -> Int {
        return 1
    }
    
}