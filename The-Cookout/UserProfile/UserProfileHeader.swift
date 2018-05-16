//
//  UserProfileHeader.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Kingfisher
import LBTAComponents
import Firebase

class UserProfileHeader: DatasourceCell {
    
    var user: User? {
        didSet {
            setupProfileImage()
            nameLabel.text = user?.name
            
            setupEditFollowButton()
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            //edit profile
            
        } else {
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value) { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    
                    UIView.performWithoutAnimation {
                        self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                        self.editProfileFollowButton.layoutIfNeeded()
                    }
                    
                } else {
                    self.setupFollowStyle()
                }
            }
        }
    }
    
    @objc func handleEditProfileOrFollow() {
        print("Execute edit profile / follow / unfollow logic...")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            
            //unfollow
            guard let user = self.user else { return }
            
            let alertController = UIAlertController(title: "Unfollow \(user.name)?", message: "Are you sure you want to unfollow \(user.name)?", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (_) in
                
                do {
                    Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                        if let err = err {
                            print("Failed to unfollow user:", err)
                            return
                        }
                        
                        print("Successfully unfollowed user:", self.user?.username ?? "")
                        
                        self.setupFollowStyle()
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)

        } else {
            
            //follow
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                
                print("Successfully followed user: ", self.user?.username ?? "")
                UIView.performWithoutAnimation {
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    self.editProfileFollowButton.layoutIfNeeded()
                }
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    fileprivate func setupFollowStyle() {
        UIView.performWithoutAnimation {
            self.editProfileFollowButton.setTitle("Follow", for: .normal)
            self.editProfileFollowButton.layoutIfNeeded()
        }
        self.editProfileFollowButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    
    fileprivate func setupProfileImage() {
        guard let url = user?.profileImageUrl else { return }
        self.profileImageView.loadImage(urlString: url)
        
        DispatchQueue.main.async {
            self.profileImageView.loadImage(urlString: url)
        }
    }
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.layer.cornerRadius = 40
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let listButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "list").resizeImage(targetSize: CGSize(width: 30, height: 30))
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    let gridButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "grid").resizeImage(targetSize: CGSize(width: 30, height: 30))
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.1)
        
        return btn
    }()
    
    let likesButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "likes_folder").resizeImage(targetSize: CGSize(width: 30, height: 30))
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.1)
        return btn
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        let fontStyle = UIFont.boldSystemFont(ofSize: 12)
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font: fontStyle])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray,  NSAttributedStringKey.font: fontStyle]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let fontStyle = UIFont.boldSystemFont(ofSize: 12)
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: fontStyle])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray,  NSAttributedStringKey.font: fontStyle]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let fontStyle = UIFont.boldSystemFont(ofSize: 12)
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: fontStyle])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray,  NSAttributedStringKey.font: fontStyle]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(profileImageView)
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        
        setupBottomToolBar()
        
        addSubview(nameLabel)
        nameLabel.anchor(profileImageView.bottomAnchor, left: leftAnchor, bottom: listButton.topAnchor, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 34)
    }
    
    fileprivate func setupBottomToolBar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        let stackView = UIStackView(arrangedSubviews: [listButton, gridButton, likesButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
    
        addSubview(stackView)
    
        stackView.anchor(topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 50)
    }

}
