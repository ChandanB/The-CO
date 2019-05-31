//
//  InformationMessageSender.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase


class InformationMessageSender: NSObject {
    
  func sendInformatoinMessage(chatID: String?, membersIDs: [String], text: String) {
    
    let childRef = MESSAGES_REF.childByAutoId()
    let defaultMessageStatus = messageStatusDelivered
    guard let toId = chatID, let fromId = CURRENT_USER?.uid else { return }
		guard let childRefKey = childRef.key else { return }
    
    let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
    let values: [String: AnyObject] = ["messageUID": childRefKey as AnyObject, "toId": toId as AnyObject, "status": defaultMessageStatus as AnyObject, "seen": false as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp, "text": text as AnyObject, "isInformationMessage": true as AnyObject]
    
    childRef.updateChildValues(values) { (error, _) in
      guard error == nil, let messageId = childRef.key else { return }
     
      
      for memberID in membersIDs {
        let currentUserMessages = USER_MESSAGES_REF.child(memberID).child(toId).child(userMessagesFirebaseFolder)
        currentUserMessages.updateChildValues([messageId: 1])
      }
      
      self.incrementBadgeForReciever(conversationID: chatID, participantsIDs: membersIDs)
      self.setupMetadataForSender(chatID: chatID)
      self.updateLastMessageForMembers(chatID: chatID, participantsIDs: membersIDs, messageID: messageId)
    }
  }

  func updateLastMessageForMembers(chatID: String?, participantsIDs: [String], messageID: String) {
    guard let conversationID = chatID else { return }
    for memberID in participantsIDs {
      let ref = USER_MESSAGES_REF.child(memberID).child(conversationID).child(messageMetaDataFirebaseFolder)
      let childValues: [String: Any] = ["lastMessageID": messageID]
      ref.updateChildValues(childValues)
    }
  }

  func setupMetadataForSender(chatID: String?) {
    guard let toId = chatID, let fromId = CURRENT_USER?.uid else { return }
    var ref = USER_MESSAGES_REF.child(fromId).child(toId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard !snapshot.hasChild(messageMetaDataFirebaseFolder) else { return }
      ref = ref.child(messageMetaDataFirebaseFolder)
      ref.updateChildValues(["badge": 0])
    })
  }

  func incrementBadgeForReciever(conversationID: String?, participantsIDs: [String]) {
    guard let currentUserID = CURRENT_USER?.uid, let conversationID = conversationID else { return }
    for participantID in participantsIDs where participantID != currentUserID {
      runTransaction(firstChild: participantID, secondChild: conversationID)
    }
  }
}

public func runTransaction(firstChild: String, secondChild: String) {
  var ref = USER_MESSAGES_REF.child(firstChild).child(secondChild)
  ref.observeSingleEvent(of: .value, with: { (snapshot) in
    
    guard snapshot.hasChild(messageMetaDataFirebaseFolder) else {
      ref = ref.child(messageMetaDataFirebaseFolder)
      ref.updateChildValues(["badge": 1])
      return
    }
    ref = ref.child(messageMetaDataFirebaseFolder).child("badge")
    ref.runTransactionBlock({ (mutableData) -> TransactionResult in
      var value = mutableData.value as? Int
      if value == nil { value = 0 }
      mutableData.value = value! + 1
      return TransactionResult.success(withValue: mutableData)
    })
  })
}

