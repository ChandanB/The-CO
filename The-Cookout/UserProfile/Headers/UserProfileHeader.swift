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

//    let fontStyle = UIFont.boldSystemFont(ofSize: 12)
//    let attributedText = NSMutableAttributedString(string: "\(postCount ?? 0)\n", attributes: [NSAttributedString.Key.font: fontStyle])
//    attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,  NSAttributedString.Key.font: fontStyle]))
//    postsLabel.attributedText = attributedText

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: DatasourceCell {
    
    static var cellId = "userProfileHeaderCellId"
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            reloadData()
        }
    }
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0, alpha: 0.2)
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 0.5
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let postsLabel = UserProfileStatsLabel(value: 0, title: "posts")
    private let followersLabel = UserProfileStatsLabel(value: 0, title: "followers")
    private let followingLabel = UserProfileStatsLabel(value: 0, title: "following")
    
    private lazy var followButton: UserProfileFollowButton = {
        let button = UserProfileFollowButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "Grid_icon").resizeImage(targetSize: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "List_icon").resizeImage(targetSize: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    lazy var repostsButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "circular-arrow").resizeImage(targetSize: CGSize(width: 25, height: 20))
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.3)
        return btn
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bookmarks"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
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
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        return textView
    }()
    
    
    private let padding: CGFloat = 12
    
    static var headerId = "userProfileHeaderId"
    
    let backgroundImageView: UIImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    var profileImageTopAnchor: NSLayoutConstraint?
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "FollowedUser")
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(backgroundImageView)
        backgroundImageView.fillSuperview()
        
        addSubview(profileImageView)
        profileImageView.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 120, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: maxHeight)
        profileImageView.layer.cornerRadius = maxHeight / 2
        profileImageView.heightConstraint?.constant = maxHeight
        profileImageView.heightConstraint?.isActive = true
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: -60).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        setupBottomToolBar()
        
        addSubview(nameLabel)
        addSubview(bioTextView)
        
        nameLabel.anchor(profileImageView.bottomAnchor, left: nil, bottom: bioTextView.topAnchor, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        bioTextView.anchor(nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        bioTextView.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor).isActive = true

        setupUserStatsView()
        
        addSubview(followButton)
        followButton.anchor(followersLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
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
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, repostsButton, bookmarkButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        topDividerView.anchor(stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        bottomDividerView.anchor(stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
    }
    
    func reloadData() {
        guard let user = user else { return }
        guard let font = CustomFont.proximaNovaSemibold.of(size: 15.0) else {return}
        usernameLabel.text = "@\(user.username)"
        nameLabel.text = user.name
        nameLabel.font = font
        setupUserBio(user)
        setupProfileAndBannerImage()
        reloadUserStats()
        reloadFollowButton()
    }
    
    func setupUserBio(_ user: User) {
        
        let bio = user.bio
        guard let font = CustomFont.proximaNovaAlt.of(size: 12.0) else {return}
        
        var style = StringStyle(
            .font(font),
            .lineHeightMultiple(1.8)
        )
        
        style.lineSpacing = 3
        
        let attributedString = bio.styled(with: style)
        
        bioTextView.attributedText = attributedString
        bioTextView.textAlignment = .center
        bioTextView.sizeToFit()
        bioTextView.isScrollEnabled = false
    }
    
    
    func reloadFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else {return}
        
        if currentLoggedInUserId == userId {
            followButton.type = .edit
            return
        }
        
        let previousButtonType = followButton.type
        followButton.type = .loading
        
        Database.database().isFollowingUser(withUID: userId, completion: { (following) in
            if following {
                self.followButton.type = .unfollow
            } else {
                self.followButton.type = .follow
            }
        }) { (err) in
            self.followButton.type = previousButtonType
        }
    }
    
    private func reloadUserStats() {
        guard let uid = user?.uid else { return }
        
        Database.database().numberOfPostsForUser(withUID: uid) { (count) in
            self.postsLabel.setValue(count)
        }
        
        Database.database().numberOfFollowersForUser(withUID: uid) { (count) in
            self.followersLabel.setValue(count)
        }
        
        Database.database().numberOfFollowingForUser(withUID: uid) { (count) in
            self.followingLabel.setValue(count)
        }
    }
    
    @objc private func handleTap() {
        guard let userId = user?.uid else { return }
        if followButton.type == .edit { return }
        
        let previousButtonType = followButton.type
        followButton.type = .loading
        
        if previousButtonType == .follow {
            Database.database().followUser(withUID: userId) { (err) in
                if err != nil {
                    self.followButton.type = previousButtonType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
            
        } else if previousButtonType == .unfollow {
            Database.database().unfollowUser(withUID: userId) { (err) in
                if err != nil {
                    self.followButton.type = previousButtonType
                    return
                }
                self.reloadFollowButton()
                self.reloadUserStats()
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.updateHomeFeed, object: nil)
    }
    
    fileprivate func setupProfileAndBannerImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        
        DispatchQueue.main.async {
            self.profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    @objc func handleChangeToListView() {
        listButton.tintColor = twitterBlue
        gridButton.tintColor = UIColor(white: 0, alpha: 0.4)
        delegate?.didChangeToListView()
    }
    
    @objc func handleChangeToGridView() {
        gridButton.tintColor = twitterBlue
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    var animator: UIViewPropertyAnimator!
    
    fileprivate func setupVisualEffectBlur() {
        animator = UIViewPropertyAnimator(duration: 3.0, curve: .linear, animations: { [weak self] in
            
            // treat this area as the end state of animation
            let blurEffect = UIBlurEffect(style: .regular)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            self?.backgroundImageView.addSubview(visualEffectView)
         //   self?.addSubview(visualEffectView)
            visualEffectView.fillSuperview()
        })
    }
    
    let maxHeight: CGFloat = 120
    let minHeight: CGFloat = 60

    func animate(t: CGFloat) {
        
        if t < 0 {
            profileImageView.heightConstraint?.constant = maxHeight
            profileImageView.widthConstraint?.constant = maxHeight
            return
        }
        
        let height = max(maxHeight - (maxHeight - minHeight) * t, minHeight)
        profileImageView.heightConstraint?.constant = height
        profileImageView.widthConstraint?.constant = height
    }

}

//MARK: - UserProfileStatsLabel
private class UserProfileStatsLabel: UILabel {
    
    private var value: Int = 0
    private var title: String = ""
    
    init(value: Int, title: String) {
        super.init(frame: .zero)
        self.value = value
        self.title = title
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        numberOfLines = 0
        textAlignment = .center
        setAttributedText()
    }
    
    func setValue(_ value: Int) {
        self.value = value
        setAttributedText()
    }
    
    private func setAttributedText() {
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        self.attributedText = attributedText
    }
}

//MARK: - FollowButtonType
private enum FollowButtonType {
    case loading, edit, follow, unfollow
}

//MARK: - UserProfileFollowButton
private class UserProfileFollowButton: UIButton {
    
    var type: FollowButtonType = .loading {
        didSet {
            configureButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 3
        configureButton()
    }
    
    private func configureButton() {
        switch type {
        case .loading:
            setupLoadingStyle()
        case .edit:
            setupEditStyle()
        case .follow:
            setupFollowStyle()
        case .unfollow:
            setupUnfollowStyle()
        }
    }
    
    private func setupLoadingStyle() {
        setTitle("Loading", for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        isUserInteractionEnabled = false
    }
    
    private func setupEditStyle() {
        setTitle("Edit Profile", for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        isUserInteractionEnabled = true
    }
    
    private func setupFollowStyle() {
        setTitle("Follow", for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(r: 17, g: 154, b: 237)
        layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        isUserInteractionEnabled = true
    }
    
    private func setupUnfollowStyle() {
        setTitle("Unfollow", for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .white
        isUserInteractionEnabled = true
    }
}

