//
//  HomeController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import Kingfisher
import UIFontComplete

class HomeController: DatasourceController {
    
    let homeDatasource = HomeDatasource()
    let refreshControl = UIRefreshControl()
    var isFinishedPaging = false
    var postLikesCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        self.datasource = homeDatasource
        
        setupNavigationBarItems()
        setupRefresherControl()
        fetchAllPosts()
    }
    
    
    fileprivate func setupRefresherControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.refreshControl = refreshControl
    }
    
    @objc override func handleRefresh() {
        refreshControl.beginRefreshing()
        self.homeDatasource.posts.removeAll()
        fetchAllPosts()
    }
    
    func fetchAllPosts() {
        fetchFollowingUserIds()
        fetchCurrentUserId()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("following").child(uid)
        
        // Followers
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionary.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    if self.refreshControl.isRefreshing {
                        self.refreshPage(user)
                    }
                    self.fetchPostsWithUser(user)
                })
            })
        }
    }
    
    func fetchCurrentUserId() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Current User
        Database.fetchUserWithUID(uid: uid) { (user) in
            if self.refreshControl.isRefreshing {
                self.refreshPage(user)
            }
            self.fetchPostsWithUser(user)
        }
    }
    
    var newPost: Post?
    fileprivate func refreshPage(_ user: User) {
        self.refreshControl.endRefreshing()
        
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.observeSingleEvent(of: .childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            var post = Post(user: user, dictionary: dictionary as [String : AnyObject])
            post.id = snapshot.key
            self.newPost = post
        }
    }
    
    
    fileprivate func fetchPostsWithUser(_ user: User) {
        
        var count = 15
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if self.homeDatasource.posts.count > 0 {
            let value = self.homeDatasource.posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            count = 16
        }
        
        query.queryLimited(toLast: UInt(count)).observe(.value) { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if self.homeDatasource.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                post.id = snapshot.key
                
                let ref = Database.database().reference().child("likes").child(post.id!)
                
                ref.observe(.value) { (snapshot) in
                   // guard let dictionary = snapshot.value as? [String: Any] else { return }
                    post.likeCount = Int(snapshot.childrenCount)
                }
                
                ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                        self.postLikesCount += 1
                    } else {
                        post.hasLiked = false
                    }
                    
                    if self.newPost != nil {
                        self.homeDatasource.posts.append(self.newPost!)
                        self.newPost = nil
                    }
                    
                    print(post)
                    self.homeDatasource.posts.append(post)
                    
                    self.homeDatasource.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeDatasource.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }
    
    func setupNavigationBarItems() {
        setupRightNavItem()
        setupMiddleNavItems()
        fetchUser()
    }
    
    private func setupRightNavItem() {
        let messageButton = UIButton(type: .system)
        messageButton.setImage(#imageLiteral(resourceName: "Messages_Icon").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        messageButton.addTarget(self, action: #selector(handleMessagesTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)
    }
    
    private func setupMiddleNavItems() {
        navigationItem.title = "Home"
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let navBarSeparatorView = UIView()
        navBarSeparatorView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        view.addSubview(navBarSeparatorView)
        navBarSeparatorView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.8)
    }
    
    func setupLeftNavItem(_ user: User) {
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
        navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let posts = self.homeDatasource.posts
        let post = posts[indexPath.item]
        
        let estimatedHeight = estimatedHeightForText(post.caption)
        
        if post.hasImage == "true" && post.hasText == "true" {
            var height: CGFloat = 50 + 8 + 8 + estimatedHeight
            height += view.frame.width
            return CGSize(width: view.frame.width, height: height + 72)
        } else if post.hasImage == "true" && post.hasText == "false" {
            var height: CGFloat = 50 + 8 + 8
            height += view.frame.width
            return CGSize(width: view.frame.width, height: height + 72)
        }
        
        return CGSize(width: view.frame.width, height: estimatedHeight + 128)
    }
    
    private func estimatedHeightForText(_ text: String) -> CGFloat {
        
        let approximateWidthOfTextView = view.frame.width - 12 - 50 - 12 - 4
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font: CustomFont.proximaNovaAlt.of(size: 15.0)!]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController()
        commentsController.post = post        
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func likeButtonSelected(for cell: PostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        var post = self.homeDatasource.posts[indexPath.item]
        
        guard let postId = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("likes").child(postId)
        
        let values = [uid: post.hasLiked == true ? 0 : 1]
        ref.updateChildValues(values) { (err, _) in
            
            if let err = err {
                print("Failed to like post:", err)
                return
            }
            
            print("Successfully liked post.")
            
            post.hasLiked = !post.hasLiked
     
            self.homeDatasource.posts[indexPath.item] = post
            
            self.collectionView?.reloadItems(at: [indexPath])
        }
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
    
    @objc func handleMessagesTapped() {
        let messagesController = MessagesController()
        let navigationController = UINavigationController(rootViewController: messagesController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func didTapProfilePicture(for cell: PostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let post = self.homeDatasource.posts[indexPath.item]
        let user = post.user
        userProfileController.user = user
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func didLike(for cell: PostCell) {
        
    }
    
    var user: User?
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.setupLeftNavItem(user)
          //  self.loadPosts(user)
        }
    }
    
    func loadPosts(_ user: User) {
        
        Api.posts.observePostsRemoved(user: user, withId: user.uid) { (post) in
            self.homeDatasource.posts = self.homeDatasource.posts.filter { $0.id != post.id }
            self.collectionView?.reloadData()
        }
    }
    
    @objc func handleShowSideMenu() {
        let sideMenu = SideMenu()
        present(sideMenu, animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.homeDatasource.posts.count - 1 {
            //            let user = self.homeDatasource.posts[indexPath.row].user
            //            fetchPostsWithUser(user)
            fetchAllPosts()
        }
    }
    
}
