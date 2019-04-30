//
//  HelperService.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import FirebaseStorage
import PKHUD

class HelperService {
    
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
                })
            })
        } else {
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Configuration.storageRoofRef).child("posts").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                HUD.show(.error)
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let downloadUrl = url else { return }
                let videoUrl = downloadUrl.absoluteString
                onSuccess(videoUrl)
            })
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Configuration.storageRoofRef).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                HUD.show(.error)
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let downloadUrl = url else { return }
                let photoUrl = downloadUrl.absoluteString 
                onSuccess(photoUrl)
            })
        }
    }
    
    static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = API.database.postsRef.childByAutoId().key
        let newPostReference = API.database.postsRef.child(newPostId ?? "")
        
        guard let currentUser = API.database.currentUser else { return }
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                let newHashReference = API.database.hashtagRef.child(word.lowercased())
                newHashReference.setValue([newPostId: true])
            }
        }
        
        let currentUserId = currentUser.uid
        
        var dict = ["uid": currentUserId ,"imageUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                HUD.show(.error)
                return
            }
            
            API.database.postsRef.child(currentUserId).child(newPostId ?? "").setValue(true)
            
            let myPostRef = API.database.myPostsRef.child(currentUserId).child(newPostId ?? "")
            myPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    return
                }
            })
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.show()
            onSuccess()
        })
    }
}
