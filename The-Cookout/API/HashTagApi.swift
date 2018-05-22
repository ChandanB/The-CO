//
//  HashTagApi.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import FirebaseDatabase

class HashTagApi {
    var hashtagRef = Database.database().reference().child("hashtag")
}
