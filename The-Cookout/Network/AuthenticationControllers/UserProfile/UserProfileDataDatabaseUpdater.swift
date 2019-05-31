//
//  UserProfileDataDatabaseUpdater.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase

class UserProfileDataDatabaseUpdater: NSObject {
  
  typealias UpdateUserProfileCompletionHandler = (_ success: Bool) -> Void
  func updateUserProfile(with image: UIImage, completion: @escaping UpdateUserProfileCompletionHandler) {
    
    guard let currentUserID = CURRENT_USER?.uid else { return }
    let userReference = USER_REF.child(currentUserID)
    
    let thumbnailImage = createImageThumbnail(image)
    var images = [(image: UIImage, quality: CGFloat, key: String)]()
    images.append((image: image, quality: 0.5, key: "profileImageUrl"))
    images.append((image: thumbnailImage, quality: 1, key: "thumbnailPhotoURL"))
    
    let photoUpdatingGroup = DispatchGroup()
    for _ in images { photoUpdatingGroup.enter() }
    
    photoUpdatingGroup.notify(queue: DispatchQueue.main, execute: {
      completion(true)
    })
    
    for imageElement in images {
      uploadAvatarForUserToFirebaseStorageUsingImage(imageElement.image, quality: imageElement.quality) { (url) in
        userReference.updateChildValues([imageElement.key: url], withCompletionBlock: { (_, _) in
          photoUpdatingGroup.leave()
        })
      }
    }
  }
  
  typealias DeleteCurrentPhotoCompletionHandler = (_ success: Bool) -> Void
  func deleteCurrentPhoto(completion: @escaping DeleteCurrentPhotoCompletionHandler) {
    
    guard currentReachabilityStatus != .notReachable, let currentUser = CURRENT_USER?.uid else {
      completion(false)
      return
    }
    
    let userReference = USER_REF.child(currentUser)
    userReference.observeSingleEvent(of: .value, with: { (snapshot) in
      
      guard let userData = snapshot.value as? [String: AnyObject] else { completion(false); return }
      guard let photoURL = userData["profileImageUrl"] as? String , let thumbnailPhotoURL = userData["thumbnailPhotoURL"] as? String, photoURL != "", thumbnailPhotoURL != "" else {
        completion(true)
        return
      }
      
      let storage = Storage.storage()
      let photoURLStorageReference = storage.reference(forURL: photoURL)
      let thumbnailPhotoURLStorageReference = storage.reference(forURL: thumbnailPhotoURL)
      
      let imageRemovingGroup = DispatchGroup()
      imageRemovingGroup.enter()
      imageRemovingGroup.enter()
      
      imageRemovingGroup.notify(queue: DispatchQueue.main, execute: {
        completion(true)
      })
      
      photoURLStorageReference.delete(completion: { (_) in
        userReference.updateChildValues(["profileImageUrl": ""], withCompletionBlock: { (_, _) in
          imageRemovingGroup.leave()
        })
      })
      
      thumbnailPhotoURLStorageReference.delete(completion: { (_) in
        userReference.updateChildValues(["thumbnailPhotoURL": ""], withCompletionBlock: { (_, _) in
          imageRemovingGroup.leave()
        })
      })
      
    }, withCancel: { (error) in
      completion(false)
    })
  }
}
