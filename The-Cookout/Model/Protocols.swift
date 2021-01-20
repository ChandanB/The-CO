//
//  Protocols.swift
//  The-Cookout
//
//  Created by Chandan Brown on 9/5/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import Foundation
import Firebase
import LBTAComponents


protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapUser(user: User)
    func didTapOptions(post: Post)
    func didRepost(for cell: DatasourceCell)
    func didUpvote(for cell: DatasourceCell)
    func didDownvote(for cell: DatasourceCell)
}

protocol HomePostCellHeaderDelegate {
    func didTapUser()
    func didTapOptions()
}

// MARK: - ContentViewCellProtocol
protocol ContentViewCell {
    static func identifier() -> String
}

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

protocol Content {
    var contentType: ContentType { get }
}


protocol ReturnPostImageDelegate {
    func returnPostImage(image: UIImage)
}


protocol ReturnPostTextDelegate {
    func returnPostText(text: PlaceholderTextView)
}

protocol PhotoCellDelegate {
    func presentLightBox(for cell: UserProfilePhotoCell)
    func didTapImage(_ post: Post)
}

protocol ProfileHeaderDelegate {
//    func handleEditFollowTapped(for header: UserProfileHea)
//    func setUserStats(for header: ProfileHeaderCell)
//    func handleFollowersTapped(for header: ProfileHeaderCell)
//    func handleFollowingTapped(for header: ProfileHeaderCell)
}

protocol SearchTableCellDelegate {
    func handleFollowTapped(for cell: SearchTableViewCell)
}

protocol FeedCellDelegate {
//    func handleUsernameTapped(for feedCell: HomePostCell)
//    func handleOptionsTapped(for feedCell: HomePostCell)
//    func handleLikeTapped(for feedCell: HomePostCell)
//    func handleCommentTapped(for feedCell: HomePostCell)
//    func handleConfigureLikeButton(for feedCell: HomePostCell)
//    func handleShowLikes(for feedCell: HomePostCell)
//    func handleShowMessages(for feedCell: HomePostCell)
}

protocol Printable {
    var description : String {get}
}


protocol NotificationCellDelegate {
    func followTapped (for cell: NotificationCell)
    func handlePostTapped (for cell: NotificationCell)
}

protocol MainSwipeControllerDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

// Messaging

protocol UsersUpdatesDelegate: class {
    func users(updateDatasource users: [User])
    func users(handleAccessStatus: Bool)
}

protocol SocialPointUsersUpdatesDelegate: class {
    func socialPointUsers(shouldBeUpdatedTo users: [User])
}

protocol MessageSenderDelegate: class {
    func update(with values: [String: AnyObject])
    func update(mediaSending progress: Double, animated: Bool)
}

protocol DeleteAndExitDelegate: class {
    func deleteAndExit(from conversationID: String)
}

protocol MessagesDelegate: class {
    func messages(shouldBeUpdatedTo messages: [Message], conversation: Conversation)
    func messages(shouldChangeMessageStatusToReadAt reference: DatabaseReference)
}

protocol CollectionDelegate: class {
    func collectionView(update message: Message, reference: DatabaseReference)
    func collectionView(updateStatus reference: DatabaseReference, message: Message)
}

protocol ChatLogHistoryDelegate: class {
    func chatLogHistory(isEmpty: Bool)
    func chatLogHistory(updated messages: [Message], at indexPaths: [IndexPath])
}

@objc protocol GroupMembersManagerDelegate: class {
    @objc optional func updateName(name: String)
    @objc optional func updateAdmin(admin: String)
    func addMember(id: String)
    func removeMember(id: String)
}

protocol ManageAppearance: class {
    func manageAppearance(_ chatsController: ChatsTableViewController, didFinishLoadingWith state: Bool )
}

protocol ConversationUpdatesDelegate: class {
    func conversations(didStartFetching: Bool)
    func conversations(didStartUpdatingData: Bool)
    func conversations(didFinishFetching: Bool, conversations: [Conversation])
    func conversations(update conversation: Conversation, reloadNeeded: Bool)
}

// Commenting

protocol CommentCellDelegate {
    func didTapUser(user: User)
}

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(comment: String)
}


