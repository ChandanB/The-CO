//
//  GroupMembersManager.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase


class GroupMembersManager: NSObject {

    var chatNameReference: DatabaseReference!
    var chatNameHandle: DatabaseHandle!
    var chatAdminReference: DatabaseReference!
    var chatAdminHandle: DatabaseHandle!
    var membersReference: DatabaseReference!
    var membersAddingHandle: DatabaseHandle!
    var membersRemovingHandle: DatabaseHandle!

    weak var delegate: GroupMembersManagerDelegate?

    func removeAllObservers() {
        if membersReference != nil && membersAddingHandle != nil {
            membersReference.removeObserver(withHandle: membersAddingHandle)
        }

        if membersReference != nil && membersRemovingHandle != nil {
            membersReference.removeObserver(withHandle: membersRemovingHandle)
        }

        if chatNameReference != nil && chatNameHandle != nil {
            chatNameReference.removeObserver(withHandle: chatNameHandle)
        }

        if chatAdminReference != nil && chatAdminHandle != nil {
            chatAdminReference.removeObserver(withHandle: chatAdminHandle)
        }
    }

    func observeMembersChanges(_ conversation: Conversation?) {

        guard let chatID = conversation?.chatID else { return }

        chatNameReference = Database.database().reference().child("groupChats").child(chatID).child(messageMetaDataFirebaseFolder).child("chatName")
        chatNameHandle = chatNameReference.observe(.value, with: { (snapshot) in
            guard let newName = snapshot.value as? String else { return }
            self.delegate?.updateName?(name: newName)
        })

        chatAdminReference = Database.database().reference().child("groupChats").child(chatID).child(messageMetaDataFirebaseFolder).child("admin")
        chatAdminHandle = chatAdminReference.observe(.value, with: { (snapshot) in
            guard let newAdmin = snapshot.value as? String else { return }
            self.delegate?.updateAdmin?(admin: newAdmin)
        })

        membersReference = Database.database().reference().child("groupChats").child(chatID).child(messageMetaDataFirebaseFolder).child("chatParticipantsIDs")
        membersAddingHandle = membersReference.observe(.childAdded) { (snapshot) in
            guard let id = snapshot.value as? String else { return }
            self.delegate?.addMember(id: id)
        }
        membersRemovingHandle = membersReference.observe(.childRemoved) { (snapshot) in

            guard let id = snapshot.value as? String else { return }
            self.delegate?.removeMember(id: id)
        }
    }
}
