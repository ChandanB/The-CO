//
//  HomeDatasourceController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import Kingfisher

class HomeController: DatasourceController {
    
    let homeDatasource = HomeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: PostController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        self.datasource = self.homeDatasource
        
        fetchUser()
        fetchAllPosts()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleFeedRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationBarItems()
    }
    
    @objc func handleUpdateFeed() {
        handleFeedRefresh()
    }
    
    @objc func handleFeedRefresh() {
        self.homeDatasource.posts.removeAll()
        fetchAllPosts()
    }
    
    func fetchAllPosts() {
        fetchPostFeed()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionary.forEach({ (arg) in
                let (key, value) = arg
                
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following user ids:", err)
        }
    }
    
    
    func fetchPostFeed() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user)
        }
    }
    
    fileprivate func fetchPostsWithUser(_ user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                self.homeDatasource.posts.append(post)
            })
            
            self.homeDatasource.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
        }
    }
    
    func setupNavigationBarItems() {
        setupRightNavItem()
        setupMiddleNavItems()
    }
    
    private func setupRightNavItem() {
        let messageButton = UIButton(type: .system)
        messageButton.setImage(#imageLiteral(resourceName: "message").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
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
        navBarSeparatorView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let post = self.datasource?.item(indexPath) as? Post else { return .zero }
        
        let estimatedHeight = estimatedHeightForText(post.caption)
        
        if post.imageWidth.intValue > 0 {
            var height: CGFloat = 50 + 8 + 8 + estimatedHeight
            height += view.frame.width
            return CGSize(width: view.frame.width, height: height + 72)
        }
        
        return CGSize(width: view.frame.width, height: estimatedHeight + 126)
    }
    
    private func estimatedHeightForText(_ text: String) -> CGFloat {
        
        if text == "" {
            return 10
        }
        
        let approximateWidthOfTextView = view.frame.width - 12 - 50 - 12 - 2
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    var user: User?
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.setupLeftNavItem(self.user!)
            self.collectionView?.reloadData()
        }
    }
    
}
