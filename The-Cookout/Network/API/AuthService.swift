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
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
        
    }
    
    static func signUp(bio: String, name: String, username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
                
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(filename).jpg")
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                
                guard let uid = user?.user.uid else { return }
                print("Successfully created user:", uid)
                
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    guard let downloadUrl = url else { return }
                    let profileImageUrl = downloadUrl.absoluteString
                    
                    print("Successfully uploaded profile image:", profileImageUrl)
                  
                    self.setNewUserInfomation(bio: bio, name: name, profileImageUrl: profileImageUrl, username: username, email: email, uid: uid, onSuccess: onSuccess)
                })
               
            })
        })
        
    }
    
    static func setNewUserInfomation(bio: String, name: String, profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")

        let dictionaryValues = ["name": name, "email": email, "username": username, "username_lowercase": username.lowercased(), "bio": bio, "profileImageUrl": profileImageUrl]
        let values = [uid: dictionaryValues]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to save user info into db:", err)
                return
            }
            onSuccess()
        })
    }
    
    static func setUserInfomation(bio: String, name: String, profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")

        let dictionaryValues = ["name": name, "email": email, "username": username, "username_lowercase": username.lowercased(), "bio": bio, "profileImageUrl": profileImageUrl]
        let values = [uid: dictionaryValues]
        usersReference.setValue(values)
        
        onSuccess()
    }
    
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        API.database.currentUser?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            }else {
                
                let uid = API.database.currentUser?.uid
                
                let storageRef = Storage.storage().reference(forURL: Configuration.storageRoofRef).child("profile_image").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                           print(error)
                           return
                        }
                        
                    guard let downloadUrl = url else { return }
                    let profileImageUrl = downloadUrl.absoluteString 
                    
                    self.updateDatabase(profileImageUrl: profileImageUrl, username: username, email: email, onSuccess: onSuccess, onError: onError)
                        
                    })                    
                })
            }
        })
        
    }
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]
        
        API.database.refCurrentUser?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
    
}
