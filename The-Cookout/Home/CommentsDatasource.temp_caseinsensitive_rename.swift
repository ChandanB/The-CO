//
//  CommentsDataSource.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/18/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class CommentsDatasource: Datasource {

    var comments = [Comment]()

    override func cellClasses() -> [DatasourceCell.Type] {
        return [CommentCell.self]
    }

    override func item(_ indexPath: IndexPath) -> Any? {

        return comments[indexPath.item]
    }

    override func numberOfItems(_ section: Int) -> Int {

        return comments.count
    }

    override func numberOfSections() -> Int {
        return  1
    }

}
