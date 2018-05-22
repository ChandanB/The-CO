//
//  AuthService.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/22/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
class AuthService {
    
    
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        Api.user.currentUser?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            }else {
                let uid = Api.user.currentUser?.uid
                let storageRef = Storage.storage().reference(forURL: Config.storageRoofRef).child("profile_image").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                 //   let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    
                //    self.updateDatabase(profileImageUrl: profileImageUrl!, username: username, email: email, onSuccess: onSuccess, onError: onError)
                })
            }
        })
        
    }
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "username": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
        Api.user.refCurrentUser?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
            
        })
    }
}
