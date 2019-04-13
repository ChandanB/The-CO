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
import BonMot
import UIFontComplete

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class SphereView: UIView {
    // iOS 9 specific
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

class UserProfileHeader: DatasourceCell {
    
    var user: User? {
        didSet {
            let font = CustomFont.proximaNovaSemibold.of(size: 15.0)
            setupProfileAndBannerImage()
            nameLabel.text = user?.name
            nameLabel.font = font!
            usernameLabel.text = "@\(user?.username ?? "")"
            setupUserBio(user!)
            setupEditFollowButton()
        }
    }

    var delegate: UserProfileHeaderDelegate?
    
    var contentOffsetY = 0
    
    var postCount: Int? {
        didSet {
            let fontStyle = UIFont.boldSystemFont(ofSize: 12)
            let attributedText = NSMutableAttributedString(string: "\(postCount ?? 0)\n", attributes: [NSAttributedString.Key.font: fontStyle])
            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,  NSAttributedString.Key.font: fontStyle]))
            postsLabel.attributedText = attributedText
        }
    }
    
    var followersCount: Int? {
        didSet {
            let fontStyle = UIFont.boldSystemFont(ofSize: 12)
            let attributedText = NSMutableAttributedString(string: "\(followersCount ?? 0)\n", attributes: [NSAttributedString.Key.font: fontStyle])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,  NSAttributedString.Key.font: fontStyle]))
            followersLabel.attributedText = attributedText
        }
    }

    var followingCount: Int? {
        didSet {
            let fontStyle = UIFont.boldSystemFont(ofSize: 12)
            let attributedText = NSMutableAttributedString(string: "\(followingCount ?? 0)\n", attributes: [NSAttributedString.Key.font: fontStyle])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,  NSAttributedString.Key.font: fontStyle]))
            followingLabel.attributedText = attributedText
        }
    }
    
    func setupUserBio(_ user: User) {
        
        let bio = user.bio
        let font = CustomFont.proximaNovaAlt.of(size: 12.0)
        
        var style = StringStyle(
            .font(font!),
            .lineHeightMultiple(1.8)
        )
        
        style.lineSpacing = 3
        
        let attributedString = bio.styled(with: style)
        
        bioTextView.attributedText = attributedString
        bioTextView.textAlignment = .center
        bioTextView.sizeToFit()
        bioTextView.isScrollEnabled = false
    }
    
    func setupEditFollowButton() {
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        let userId = user?.uid
        
        if currentLoggedInUserId == userId {
            //edit profile
            
        } else {
            // check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId!).observeSingleEvent(of: .value) { (snapshot) in
                
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
    
    fileprivate func setupFollowStyle() {
        UIView.performWithoutAnimation {
            self.editProfileFollowButton.setTitle("Follow", for: .normal)
            self.editProfileFollowButton.layoutIfNeeded()
        }
        self.editProfileFollowButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    @objc func handleEditProfileOrFollow() {
        print("Execute edit profile / follow / unfollow logic...")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = user?.uid else { return }
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            
            //Unfollow
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
            let followingRef = Database.database().reference().child("following").child(currentLoggedInUserId)
    
            let values = [userId: 1]
            followingRef.updateChildValues(values) { (err, ref) in
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
                
                let values = [currentLoggedInUserId: 1]
                let followerRef = Database.database().reference().child("followers").child((self.user?.uid)!)
                followerRef.updateChildValues(values) { (err, ref) in
                    if let err = err {
                        print("Failed to follow user:", err)
                        return
                    }
                    
                NotificationCenter.default.post(name: UserProfileHeader.updateFeedNotificationName, object: nil)
                }
            }
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "FollowedUser")
    
    lazy var likesButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "Like_icon").resizeImage(targetSize: CGSize(width: 25, height: 20))
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.3)
        return btn
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "List_icon").resizeImage(targetSize: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.3)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "grid").resizeImage(targetSize: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeToListView() {
        print("Changing to list view")
        listButton.tintColor = twitterBlue
        gridButton.tintColor = UIColor(white: 0, alpha: 0.4)
        delegate?.didChangeToListView()
    }
    
    @objc func handleChangeToGridView() {
        gridButton.tintColor = twitterBlue
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()

    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.layer.cornerRadius = 60
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let bannerImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.backgroundColor = twitterBlue
        iv.contentMode = .scaleAspectFill
        iv.alpha = 1.0
        iv.clipsToBounds = true
        return iv
    }()
    
    let backgroundImageView: UIImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        return textView
    }()
    
    let topDividerView = UIView()
    let bottomDividerView = UIView()
    
    var profileImageTopAnchor: NSLayoutConstraint?
    
    let maxHeight: CGFloat = 120
    let minHeight: CGFloat = 50
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(backgroundImageView)
     //   addSubview(bannerImageView)
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(bioTextView)
        addSubview(editProfileFollowButton)
        
        backgroundImageView.fillSuperview()
//        
//        var height = backgroundImageView.frame.height
//        
//        backgroundImageView.frame = CGRect(x: 0, y: 0, width: self.width, height: height)
        
     //   bannerImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 160)
        
       
        
        profileImageView.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 120, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: maxHeight)
        
        profileImageView.heightConstraint?.constant = maxHeight
        profileImageView.heightConstraint?.isActive = true
        
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: -60).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        
        
        nameLabel.anchor(profileImageView.bottomAnchor, left: nil, bottom: bioTextView.topAnchor, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        bioTextView.anchor(nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        bioTextView.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor).isActive = true

        setupUserStatsView()
        
        editProfileFollowButton.anchor(followersLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        setupBottomToolBar()
        
        //blur
        setupVisualEffectBlur()
    }
   
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        
        addSubview(stackView)
        
        stackView.anchor(bioTextView.bottomAnchor, left: bioTextView.leftAnchor, bottom: nil, right: bioTextView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    fileprivate func setupBottomToolBar() {
        
        topDividerView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        bottomDividerView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, likesButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        topDividerView.anchor(stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        bottomDividerView.anchor(stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
    }
    
    
    fileprivate func setupProfileAndBannerImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        
        DispatchQueue.main.async {
            self.profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    var animator: UIViewPropertyAnimator!
    
    fileprivate func setupVisualEffectBlur() {
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .linear, animations: { [weak self] in
            
          //  self?.profileImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
            // treat this area as the end state of your animation
            let blurEffect = UIBlurEffect(style: .regular)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            self?.backgroundImageView.addSubview(visualEffectView)
         //   self?.addSubview(visualEffectView)
            visualEffectView.fillSuperview()
        })
    }
    

    func animate(t: CGFloat) {
        
        if t < 0 {
            profileImageView.heightConstraint?.constant = maxHeight
            return
        }
        
        let height = max(maxHeight - (maxHeight - minHeight) * t, minHeight)
        profileImageView.heightConstraint?.constant = height
    }
    

}
