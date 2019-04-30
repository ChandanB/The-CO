//
//  HomeDatasource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class HomeDatasource: Datasource {
    
    var posts = [Post]()
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [PostCell.self]
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        if posts.count <= 0 {
            return 0
        }
        return posts[indexPath.item]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return posts.count
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
}
