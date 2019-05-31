//
//  UserProfileAvatarOpenerDelegate.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

extension UserMessageProfileController: AvatarOpenerDelegate {
  func avatarOpener(avatarPickerDidPick image: UIImage) {
    userProfileContainerView.profileImageView.showActivityIndicator()
    userProfileDataDatabaseUpdater.deleteCurrentPhoto { (isDeleted) in
      self.userProfileDataDatabaseUpdater.updateUserProfile(with: image, completion: { (isUpdated) in
        self.userProfileContainerView.profileImageView.hideActivityIndicator()
        guard isUpdated else {
          basicErrorAlertWith(title: basicErrorTitleForAlert, message: thumbnailUploadError, controller: self)
          return
        }
        self.userProfileContainerView.profileImageView.image = image
       
      })
    }
  }
  
  func avatarOpener(didPerformDeletionAction: Bool) {
    userProfileContainerView.profileImageView.showActivityIndicator()
    userProfileDataDatabaseUpdater.deleteCurrentPhoto { (isDeleted) in
      self.userProfileContainerView.profileImageView.hideActivityIndicator()
      guard isDeleted else {
           basicErrorAlertWith(title: basicErrorTitleForAlert, message: deletionErrorMessage, controller: self)
        return
      }
      self.userProfileContainerView.profileImageView.image = nil
    }
  }
}
