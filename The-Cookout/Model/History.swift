//
//  History.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

struct HistoriesContent: Content {
    let contentType: ContentType = .histories
    let histories:[History]
    
    init(histories: [History]) {
        self.histories = histories
    }
}

struct History {
    let name: String
    let profileUrl: String
    let histories: [String]
    let isSelfPost: Bool
    
    init(name: String, profileUrl: String, histories: [String], isSelfPost: Bool) {
        self.name = name
        self.profileUrl = profileUrl
        self.histories = histories
        self.isSelfPost = isSelfPost
    }
}
