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

class HomeDatasourceController: DatasourceController {
    
    var user: User?
    var userFeed: [User?] = []
    var postFeed: [Post?] = []
    
    let homeDatasource = HomeDataSource()
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        fetchUser()
        fetchUserFeed()
        fetchPostFeed()
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(HomeDatasourceController.populate), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        setupNavigationBarItems()
    }
    
    func setupNavigationBarItems() {
        setupRightNavItem()
        setupMiddleNavItems()
    }
    
    private func setupRightNavItem() {
        let newPostButton = UIButton(type: .system)
        newPostButton.setImage(#imageLiteral(resourceName: "new_post").withRenderingMode(.alwaysOriginal), for: .normal)
        newPostButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        newPostButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newPostButton)
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
        
        fetchImage(with: user.profileImageUrl) { (image) in
            profileButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            profileButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
            profileButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
            profileButton.layer.cornerRadius = 17
            profileButton.layer.masksToBounds = true
            profileButton.imageView?.contentMode = .scaleAspectFill
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.leftBarButtonItem?.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
    }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                
                //what happens? we need to present some kind of login controller
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
    
    @objc func populate() {
        DispatchQueue.main.async {
            self.datasource = self.homeDatasource
            self.collectionView?.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            if let user = self.datasource?.item(indexPath) as? User {
                let estimatedHeight = estimatedHeightForText(user.bio)
                return CGSize(width: view.frame.width, height: estimatedHeight + 66)
            }
        } else if indexPath.section == 1 {
            guard let post = self.datasource?.item(indexPath) as? Post else { return .zero }
            let estimatedHeight = estimatedHeightForText(post.text)
            return CGSize(width: view.frame.width, height: estimatedHeight + 74)
        }
        return CGSize(width: view.frame.width, height: 200)
    }
    
    private func estimatedHeightForText(_ text: String) -> CGFloat {
        let approximateWidthOfBioTextView = view.frame.width - 12 - 50 - 12 - 2
        let size = CGSize(width: approximateWidthOfBioTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 1 {
            return .zero
        }
        
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if section == 1 {
            return .zero
        }
        
        return CGSize(width: view.frame.width, height: 64)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            self.user = User(dictionary: dictionary as [String : AnyObject])
            
            self.setupLeftNavItem(self.user!)
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
    
    
}
