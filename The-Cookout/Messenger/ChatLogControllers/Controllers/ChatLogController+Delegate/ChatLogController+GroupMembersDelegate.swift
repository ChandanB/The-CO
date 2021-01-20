//
//  ChatLogController+GroupMembersDelegate.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase

extension ChatLogController: GroupMembersManagerDelegate {

  func updateName(name: String) {
    self.conversation?.chatName = name
    if self.isCurrentUserMemberOfCurrentGroup() {
      self.configureTitleViewWithOnlineStatus()
    }
  }

  func updateAdmin(admin: String) {
    self.conversation?.admin = admin
  }

  func addMember(id: String) {
    guard let members = self.conversation?.chatParticipantsIDs else { return }

		if let _ = members.firstIndex(where: { (memberID) -> Bool in
      return memberID == id }) {
    } else {
      self.conversation?.chatParticipantsIDs?.append(id)
      self.changeUIAfterChildAddedIfNeeded()
    }
  }

  func removeMember(id: String) {
    guard let members = self.conversation?.chatParticipantsIDs else { return }

		guard let memberIndex = members.firstIndex(where: { (memberID) -> Bool in
      return memberID == id
    }) else { return }

    self.conversation?.chatParticipantsIDs?.remove(at: memberIndex)
    self.changeUIAfterChildRemovedIfNeeded()
  }

  func isCurrentUserMemberOfCurrentGroup() -> Bool {
    guard let membersIDs = conversation?.chatParticipantsIDs,
      let uid = CURRENT_USER?.uid, membersIDs.contains(uid) else { return false }
    return true
  }

  func changeUIAfterChildAddedIfNeeded() {
    if isCurrentUserMemberOfCurrentGroup() {
      configureTitleViewWithOnlineStatus()
      if typingIndicatorReference == nil {
        reloadInputViews()
        observeTypingIndicator()
        navigationItem.rightBarButtonItem?.isEnabled = true
      }
    }
  }

  func changeUIAfterChildRemovedIfNeeded() {
    if isCurrentUserMemberOfCurrentGroup() {
      configureTitleViewWithOnlineStatus()
    } else {
      inputContainerView.inputTextView.resignFirstResponder()
      handleTypingIndicatorAppearance(isEnabled: false)
      removeSubtitleInGroupChat()
      reloadInputViews()
      navigationItem.rightBarButtonItem?.isEnabled = false
      guard typingIndicatorReference != nil else { return }
      typingIndicatorReference.removeAllObservers()
      typingIndicatorReference = nil
    }
  }

  fileprivate func removeSubtitleInGroupChat() {
    if let isGroupChat = conversation?.isGroupChat, isGroupChat, let title = conversation?.chatName {
      let subtitle = ""
      navigationItem.setTitle(title: title, subtitle: subtitle)
      return
    }
  }
}
