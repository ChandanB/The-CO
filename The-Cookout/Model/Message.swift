//
//  Message.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase

struct Message {
    
    let text: String?
    let toId: String?
    let fromId: String?
    let imageUrl: String?
    let videoUrl: String?
    let timestamp: NSNumber?
    let imageWidth: NSNumber?
    let imageHeight: NSNumber?
    
    let creationDate: Date
    
    init(dictionary: [String: AnyObject]) {
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.fromId = dictionary["fromId"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.videoUrl = dictionary["videoUrl"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}
