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
import Nora
import Result

class HomeController: HomePostCellViewController, UICollectionViewDelegateFlowLayout {
    
    let refreshControl = UIRefreshControl()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().fetchCurrentUser { (user) in
            self.user = user
            self.configureNavigationBar(user)
        }
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: HomePostCell.cellId)
        collectionView?.backgroundView = HomeEmptyStateView()
        collectionView?.backgroundView?.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name.updateHomeFeed, object: nil)
        
        self.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.refreshControl.layer.zPosition = -1
        collectionView?.refreshControl = self.refreshControl
        
        fetchAllPosts()
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
        messageButton.addTarget(self, action: #selector(handleMessagesTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)
        
        //        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo").withRenderingMode(.alwaysOriginal))
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "inbox").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        //        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func fetchAllPosts() {
        showEmptyStateViewIfNeeded()
        fetchUsers()
    }
    
    private func fetchUsers() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchCurrentUser { (user) in
            self.queryPosts(forUser: user)
        }
        
        Database.database().fetchFollowing(userId: currentLoggedInUserId) { (user) in
            self.queryPosts(forUser: user)
        }
        
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    private func queryPosts(forUser user: User) {
        Database.database().queryPosts(forUser: user, posts: self.posts, completion: { (posts) in
            self.posts = posts
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        })
    }
    
    override func showEmptyStateViewIfNeeded() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        Database.database().numberOfFollowingForUser(withUID: currentLoggedInUserId) { (followingCount) in
            Database.database().numberOfPostsForUser(withUID: currentLoggedInUserId, completion: { (postCount) in
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
    
    @objc private func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
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
    
    private func estimatedHeightForText(_ text: String) -> CGFloat {
        
        let approximateWidthOfTextView = view.frame.width - 12 - 50 - 12 - 4
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedString.Key.font: CustomFont.proximaNovaAlt.of(size: 16.0)!]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
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
    
    @objc func handleMessagesTapped() {
        let messagesController = MessagesController()
        messagesController.user = self.user
        let navigationController = UINavigationController(rootViewController: messagesController)
        present(navigationController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.posts.count - 1 {
            fetchAllPosts()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as! HomePostCell
        if indexPath.item < posts.count {
            cell.datasourceItem = posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let posts = self.posts
        let post = posts[indexPath.item]
        
        let estimatedTextHeight = estimatedHeightForText(post.caption)
        let estimatedImageHeight = estimatedHeightForImage(post.imageHeight, width: post.imageWidth)
        let width = view.frame.width / 1.04
        
        if post.hasImage == true && post.hasText == true {
            let height: CGFloat = estimatedImageHeight + estimatedTextHeight
            return CGSize(width: width, height: height + 128)
        } else if post.hasImage == true && post.hasText == false {
            let height: CGFloat = estimatedImageHeight
            return CGSize(width: width, height: height + 128)
        } else {
            return CGSize(width: width, height: estimatedTextHeight + 128)
        }
    }
    
}
