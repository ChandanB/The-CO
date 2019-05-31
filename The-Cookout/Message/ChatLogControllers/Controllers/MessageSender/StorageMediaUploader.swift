//
//  StorageMediaUploader.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase

class StorageMediaUploader: NSObject {
  
  func upload(_ image: UIImage, progress: ((_ progress: StorageTaskSnapshot?) -> Void)? = nil, completion: @escaping (_ imageUrl: String) -> ()) {
    let imageName = UUID().uuidString
    let ref = STORAGE_MESSAGE_IMAGES_REF.child(imageName)

    guard let uploadData =  image.jpegData(compressionQuality: 1) else { return }
    let uploadTask = ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
      guard error == nil else { return }
      
      ref.downloadURL(completion: { (url, error) in
        guard error == nil, let imageURL = url else { completion(""); return }
        completion(imageURL.absoluteString)
      })
    })
    uploadTask.observe(.progress) { (progressSnap) in
      progress!(progressSnap)
    }
  }
  
  func upload(_ uploadData: Data, progress: ((_ progress: StorageTaskSnapshot?) -> Void)? = nil, completion: @escaping (_ videoUrl: String) -> ()) {
    
    let videoName = UUID().uuidString + ".mov"
    let ref = STORAGE_MESSAGE_VIDEO_REF.child(videoName)
    
    let uploadTask = ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
      guard error == nil else { return }
      ref.downloadURL(completion: { (url, error) in
        guard error == nil, let videoURL = url else { completion(""); return }
        completion(videoURL.absoluteString)
      })
    })
    uploadTask.observe(.progress) { (progressSnap) in
      progress!(progressSnap)
    }
  }
}

