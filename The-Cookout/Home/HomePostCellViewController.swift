//
//  HomePostCellViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/2/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//


import UIKit
import Firebase
import LBTAComponents

class HomePostCellViewController: UICollectionViewController, HomePostCellDelegate {
   
    var posts = [Post]()
    
    func showEmptyStateViewIfNeeded() {}
    
    //MARK: - HomePostCellDelegate
    func didTapComment(post: Post) {
        let commentsController = CommentsController()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapUser(user: User) {
        let layout = StretchyHeaderLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func didTapOptions(post: Post) {
        guard let currentLoggedInUserId = CURRENT_USER?.uid else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if currentLoggedInUserId == post.user.uid {
            if let deleteAction = deleteAction(forPost: post) {
                alertController.addAction(deleteAction)
            }
        } else {
            if let unfollowAction = unfollowAction(forPost: post) {
                alertController.addAction(unfollowAction)
            }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAction(forPost post: Post) -> UIAlertAction? {
        guard let currentLoggedInUserId = CURRENT_USER?.uid else { return nil }
        
        let action = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            
            let alert = UIAlertController(title: "Delete Post?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
                
                Database.database().deletePost(withUID: currentLoggedInUserId, postId: post.id ?? "") { (_) in
                    if let postIndex = self.posts.firstIndex(where: {$0.id == post.id}) {
                        self.posts.remove(at: postIndex)
                        self.collectionView?.reloadData()
                        self.showEmptyStateViewIfNeeded()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        })
        return action
    }
    
    private func unfollowAction(forPost post: Post) -> UIAlertAction? {
        let action = UIAlertAction(title: "Unfollow", style: .destructive) { (_) in
            
            let uid = post.user.uid
            Database.database().unfollowUser(withUID: uid, completion: { (_) in
                let filteredPosts = self.posts.filter({$0.user.uid != uid})
                self.posts = filteredPosts
                self.collectionView?.reloadData()
                self.showEmptyStateViewIfNeeded()
            })
        }
        return action
    }
    
    func didRepost(for cell: DatasourceCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        guard let uid = CURRENT_USER?.uid else { return }
        
        var post = posts[indexPath.item]
        
        if post.repostedByCurrentUser {
            Database.database().reference().child("reposts").child(post.id ?? "").child(uid).removeValue { (err, _) in
                if let err = err {
                    print("Failed to unrepost post:", err)
                    return
                }
                post.repostedByCurrentUser = false
                post.repostCount = post.repostCount - 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        } else {
            let values = [uid : 1]
            Database.database().reference().child("reposts").child(post.id ?? "").updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to repost post:", err)
                    return
                }
                post.repostedByCurrentUser = true
                post.repostCount = post.repostCount + 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    func didUpvote(for cell: DatasourceCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        guard let uid = CURRENT_USER?.uid else { return }
        
        var post = posts[indexPath.item]
        
        if post.upvotedByCurrentUser {
            Database.database().reference().child("upvotes").child(post.id ?? "").child(uid).removeValue { (err, _) in
                if let err = err {
                    print("Failed to unupvote post:", err)
                    return
                }
                
                post.upvotedByCurrentUser = false
                post.upvoteCount = post.upvoteCount - 1
                post.overallVoteCount = post.overallVoteCount - 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        } else {
            let values = [uid : 1]
            Database.database().reference().child("upvotes").child(post.id ?? "").updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to upvote post:", err)
                    return
                }
                
                if post.downvotedByCurrentUser {
                    post.downvotedByCurrentUser = false
                    post.downvoteCount = post.downvoteCount + 1
                }
                
                post.upvotedByCurrentUser = true
                post.upvoteCount = post.upvoteCount + 1
                post.overallVoteCount = post.overallVoteCount + 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    func didDownvote(for cell: DatasourceCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        guard let uid = CURRENT_USER?.uid else { return }
        
        var post = posts[indexPath.item]
        
        if post.downvotedByCurrentUser {
            Database.database().reference().child("downvotes").child(post.id ?? "").child(uid).removeValue { (err, _) in
                if let err = err {
                    print("Failed to undownvote post:", err)
                    return
                }
                post.downvotedByCurrentUser = false
                post.downvoteCount = post.downvoteCount + 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        } else {
            let values = [uid : 1]
            Database.database().reference().child("downvotes").child(post.id ?? "").updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to downvote post:", err)
                    return
                }
                
                if post.upvotedByCurrentUser {
                    post.upvotedByCurrentUser = false
                    post.upvoteCount = post.upvoteCount - 1
                }
                
                post.downvotedByCurrentUser = true
                post.downvoteCount = post.downvoteCount - 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        }
    }
}
