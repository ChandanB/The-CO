//
//  CommentsController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/18/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import Spring

class CommentsController: DatasourceController {

    var post: Post? {
        didSet {
            fetchComments()
        }
    }

    let commentsDatasource = CommentsDatasource()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Comments"

        self.datasource = commentsDatasource

        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive

        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -80, right: 0)

        collectionView?.register(CommentPostCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CommentCell.cellId)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchComments), for: .valueChanged)
        collectionView?.refreshControl = refreshControl

    }

    @objc fileprivate func fetchComments() {
        guard let post = self.post else { return }
        guard let id = post.id else {return}
        collectionView?.refreshControl?.beginRefreshing()
        Database.database().fetchCommentsForPost(withId: id, completion: { (comments) in
            self.commentsDatasource.comments = comments
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (_) in
            print("Couldn't fetch comments")
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CommentCell.cellId, for: indexPath) as! CommentPostCell
        header.post = self.post
        header.datasourceItem = self.post
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let post =  self.post else { return .zero }

        let estimatedTextHeight = estimatedHeightForText(post.caption)
        let estimatedImageHeight = estimatedHeightForImage(post.imageHeight, width: post.imageWidth)

        if post.hasImage && post.hasText {
            let height: CGFloat = estimatedImageHeight + estimatedTextHeight
            return CGSize(width: view.frame.width, height: height + 128)
        } else if post.hasImage && !post.hasText {
            let height: CGFloat = estimatedImageHeight
            return CGSize(width: view.frame.width, height: height + 128)
        } else {
            return CGSize(width: view.frame.width, height: estimatedTextHeight + 128)
        }
    }

    private func estimatedHeightForText(_ text: String) -> CGFloat {

        let approximateWidthOfTextView = view.frame.width - 12 - 50 - 12 - 4
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedString.Key.font: CustomFont.proximaNovaAlt.of(size: 15.0)!]

        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return estimatedFrame.height
    }

    private func estimatedHeightForImage(_ height: NSNumber, width: NSNumber) -> CGFloat {
        let h = CGFloat(truncating: height)
        let w = CGFloat(truncating: width)
        let size = h * view.frame.width / w
        return size
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.datasourceItem = self.commentsDatasource.comments[indexPath.item]
        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)

        let height = max(40 + 8 + 8, estimatedSize.height)

        return CGSize(width: view.frame.width, height: height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    lazy var commentInputAccessoryView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()

    override var inputAccessoryView: UIView? {
        get {
            return commentInputAccessoryView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension CommentsController: CommentInputAccessoryViewDelegate {
    func didSubmit(comment: String) {
        guard let postId = post?.id else { return }
        Database.database().addCommentToPost(withId: postId, text: comment) { (err) in
            if err != nil {
                return
            }
            self.commentInputAccessoryView.clearCommentTextField()
            self.dismissKeyboard()
            self.fetchComments()
        }
    }
}

// MARK: - CommentCellDelegate
extension CommentsController: CommentCellDelegate {
    func didTapUser(user: User) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}
