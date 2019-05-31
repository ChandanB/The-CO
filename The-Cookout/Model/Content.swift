//
//  Content.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

protocol Content {
    var contentType: ContentType { get }
}

enum ContentType: Int {
    case post
    case community
    case jobAd
    case histories
}
