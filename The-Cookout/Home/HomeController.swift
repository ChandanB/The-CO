//
//  HomeController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import UIFontComplete

class HomeController: HomePostCellViewController {

    var user: User? {
        didSet {
            guard let user = self.user else {return}
            configureNavigationBar(user)
        }
    }

    var datasource: [Content] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // Fields
    fileprivate let transition = CircularTransition()

    var isFinishedPaging = false

    var currentKey: String?
    private let initialPostsCount: UInt = 5
    private let furtherPostsCount: UInt = 6

    var viewSinglePost : Bool = false
    var post: Post?

    var userProfileController: UserProfileController?

    var messageNotificationView: MessageNotificationView = {
        let view = MessageNotificationView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()

        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: .updateHomeFeed, object: nil)

        self.navigationItem.title = !viewSinglePost ? "Home" : "Post"

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.refreshControl = refreshControl

        fetchPosts()
        setUserFCMToken()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = fbBg

        // UICollectionViewCell
        collectionView.register(HistoriesContentViewCell.self, forCellWithReuseIdentifier: HistoriesContentViewCell.identifier())
        collectionView.register(CommunityPostContentViewCell.self, forCellWithReuseIdentifier: CommunityPostContentViewCell.identifier())
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: HomePostCell.identifier())

        // UICollectionReusableView
        collectionView.register(UserNewPostViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserNewPostViewCell.identifier())

        //    collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        collectionView?.backgroundView = HomeEmptyStateView()
        collectionView?.backgroundView?.alpha = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUnreadMessageCount()
    }

    func setUnreadMessageCount() {
        if !viewSinglePost {
            getUnreadMessageCount { (unreadMessageCount) in
                guard unreadMessageCount != 0 else { return }
                self.navigationController?.navigationBar.addSubview(self.messageNotificationView)
                self.messageNotificationView.anchor(top: self.navigationController?.navigationBar.topAnchor, left: nil, bottom: nil, right: self.navigationController?.navigationBar.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 20, height: 20)
                self.messageNotificationView.layer.cornerRadius = 20 / 2
                self.messageNotificationView.notificationLabel.text = "\(unreadMessageCount)"
            }
        }
    }

    func getUnreadMessageCount(withCompletion completion: @escaping(Int) -> Void) {
        guard let currentUid = CURRENT_USER?.uid else { return }
        var unreadCount = 0

        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key

            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key

                MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
                    guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }

                    let message = Message(dictionary: dictionary)

                    if message.fromId != currentUid {
                        if !message.seen {
                            unreadCount += 1
                        }
                    }
                    completion(unreadCount)
                }
            })
        }
    }

    @objc func didTapMessages() {
        NotificationCenter.default.post(name: .scrollToMessages, object: nil)
    }

    @objc private func handleRefresh() {
        datasource.removeAll(keepingCapacity: true)
        posts.removeAll(keepingCapacity: true)
        self.currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }

    private func fetchPosts() {
        guard let currentUserId =  CURRENT_USER?.uid else { return }
        guard let user = self.user else {return}

        showEmptyStateViewIfNeeded()

        if viewSinglePost {
            guard let post = post else {return}
            posts.append(post)
            return
        }

        Database.database().fetchPostsForUser(databaseRef: USER_FEED_REF.child(currentUserId), currentKey: self.currentKey, user: user, initialCount: self.initialPostsCount, furtherCount: self.furtherPostsCount, lastPostId: { (first) in
            self.collectionView.refreshControl?.endRefreshing()
            self.currentKey = first.key
        }) { (post) in
            print (post)
            self.posts.append(post)
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            self.collectionView.reloadData()
        }

    }

    override func showEmptyStateViewIfNeeded() {
        guard let currentUserId = CURRENT_USER?.uid else { return }
        Database.database().numberOfFollowingForUser(withUID: currentUserId) { (followingCount) in
            Database.database().numberOfPostsForUser(withUID: currentUserId, completion: { (postCount) in
                if followingCount == 0 && postCount == 0 {
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                        self.collectionView?.backgroundView?.alpha = 1
                    }, completion: nil)
                } else {
                    self.collectionView?.backgroundView?.alpha = 0
                }
            })
        }
    }

    @objc private func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 0, bottom: 10, right: 0)
    }

    @objc func handleOpen() {
        (UIApplication.shared.keyWindow?.rootViewController as? BaseSlidingController)?.openMenu()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }

    private func estimatedHeightForImage(_ height: NSNumber, width: NSNumber) -> CGFloat {
        let h = CGFloat(truncating: height)
        let w = CGFloat(truncating: width)
        let size = h * view.frame.width / w
        return size
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }

    func likeAnimation(_ heartPopup: UIImageView) {
        UIView.animate(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
            heartPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            heartPopup.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.6, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                heartPopup.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    heartPopup.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    heartPopup.alpha = 0.0
                }, completion: {(_ finished: Bool) -> Void in
                    heartPopup.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            })
        })
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if posts.count > initialPostsCount - 1 && indexPath.item == self.posts.count - 1{
            fetchPosts()
        }

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = self.posts[indexPath.row]

        switch item.contentType {
        case .histories:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoriesContentViewCell.identifier(), for: indexPath) as! HistoriesContentViewCell
            cell.data = item as? HistoriesContent
            cell.delegate = self as HistoryDelegate
            return cell
        case .community:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityPostContentViewCell.identifier(), for: indexPath) as! CommunityPostContentViewCell
            cell.data = item as? CommunityPost
            return cell
        case .post:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.identifier(), for: indexPath) as! HomePostCell
            cell.data = item as? Post
            cell.delegate = self
            cell.hasImage = post?.hasImage
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    private func configureNavigationBar(_ user: User) {

        // Left
        let profileButton = UIButton(type: .system)
        let url = user.profileImageUrl
        let fetchImage = FetchImage()

        fetchImage.fetch(with: url) { (image) in
            profileButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }

        profileButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        profileButton.layer.cornerRadius = 17
        profileButton.layer.masksToBounds = true
        profileButton.imageView?.contentMode = .scaleAspectFill

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpen)))

        // Middle
        navigationItem.title = "Home"
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        let navBarSeparatorView = UIView()
        navBarSeparatorView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        view.addSubview(navBarSeparatorView)
        navBarSeparatorView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.8)

        // Right
        let messageButton = UIButton(type: .system)
        messageButton.setImage(#imageLiteral(resourceName: "Messages_Icon").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        messageButton.addTarget(self, action: #selector(didTapMessages), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)

        //        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo").withRenderingMode(.alwaysOriginal))
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "inbox").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        //        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //        navigationItem.backBarButtonItem?.tintColor = .black
    }

    func setUserFCMToken() {
        guard let currentUid = CURRENT_USER?.uid else { return }
        guard let fcmToken = Messaging.messaging().fcmToken else { return }

        let values = ["fcmToken": fcmToken]

        USERS_REF.child(currentUid).updateChildValues(values)
    }

}

extension HomeController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.frame.width / 1.04

        let item = self.posts[indexPath.row]

        switch item.contentType {
        case .histories:
            return CGSize(width: view.bounds.width, height: 210)
        case .community:
            guard let post = item as? CommunityPost else { return .zero }
            let estimatedTextHeight = post.calculateViewHeight(withView: view, viewOffset: 128)

            return CGSize(width: view.bounds.width, height: estimatedTextHeight)
        case .post:
            guard let post = item as? Post else { return .zero }

            let estimatedTextHeight = post.calculateViewHeight(withView: view, viewOffset: 128)

            if post.hasImage {
                let estimatedImageHeight = estimatedHeightForImage(post.imageHeight, width: post.imageWidth)
                let height: CGFloat = estimatedImageHeight + estimatedTextHeight
                return CGSize(width: width, height: height)
            } else {
                return CGSize(width: width, height: estimatedTextHeight)
            }

        default:
            return CGSize(width: view.bounds.width, height: 60)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width - 32, height: 100)
    }

    // MARK: - UIScrollViewDelegate
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if velocity.y > 0 {
            UIView.animate(withDuration: 2.5, delay: 0, options: [], animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: nil)

        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: [], animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let viewCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserNewPostViewCell.identifier(), for: indexPath) as! UserNewPostViewCell
        return viewCell
    }

}

extension HomeController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = (presented as! StoryViewController).data.position
        transition.circleColor = fbBlueLight

        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = (dismissed as! StoryViewController).data.position
        transition.circleColor = fbBlueLight

        return transition
    }

    func handleHashtagTapped(forCell cell: HomePostCell<Post>) {
        cell.captionLabel.handleHashtagTap { (hashtag) in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }

    func handleMentionTapped(forCell cell: HomePostCell<Post>) {
        cell.captionLabel.handleMentionTap { (username) in
            self.getMentionedUser(withUsername: username)
        }
    }
}

extension HomeController: HistoryDelegate {
    func didSelectHistory(history: HistoryTransitionObject) {
        let storyViewController = StoryViewController()
        storyViewController.data = history
        storyViewController.transitioningDelegate = self
        storyViewController.modalPresentationStyle = .custom

        present(storyViewController, animated: true, completion: nil)
    }
}
