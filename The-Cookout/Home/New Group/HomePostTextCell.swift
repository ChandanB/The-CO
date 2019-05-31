//
//  PostCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//
// Proxima Nova Alt ["ProximaNovaA-Bold", "ProximaNovaA-Regular", "ProximaNovaA-Black"]
// Proxima Nova ["ProximaNova-Semibold", "ProximaNovaT-Thin"]
// Proxima Nova ScOsf ["ProximaNovaS-Thin"]
// Proxima Nova Alt Condensed ["ProximaNovaACond-Semibold"]


import LBTAComponents
import UIFontComplete
import Spring
import AVFoundation
import SDWebImage
import Firebase
import ActiveLabel

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapUser(user: User)
    func didTapOptions(post: Post)
    func didRepost(for cell: DatasourceCell)
    func didUpvote(for cell: DatasourceCell)
    func didDownvote(for cell: DatasourceCell)
}

class HomePostTextCell<PostType>: DatasourceCell, ContentViewCell where PostType: Post {
    
    public class func identifier() -> String {
        return "kPostContentViewCell"
    }
    
    var delegate: HomePostCellDelegate?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    typealias ContentType = PostType

    var data: ContentType! {
        didSet {
            onDataUpdated()
        }
    }
    
    func onDataUpdated() {
        guard let post = data else {return}
        let user = post.user
        let userProfileImageViewUrl = URL(string: user.profileImageUrl)
        
        header.post = post
        
        repostButton.setImage(post.repostedByCurrentUser == true ? #imageLiteral(resourceName: "repost").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        
        setupCounters(post)
        
        userProfileImageView.sd_setImage(with: userProfileImageViewUrl, completed: nil)
        
        setupAttributedCaption(post)
        
        if post.hasImage {
            let imageUrl = post.imageUrl
            let photoImageViewUrl = URL(string: imageUrl)
            photoImageView.sd_setImage(with: photoImageViewUrl, completed: nil)
        }
    }

    
    var hasImage: Bool?
    
    let header = HomePostCellHeader()
    
    let padding: CGFloat = 12
    
    let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 0
        let tg = UITapGestureRecognizer(target: self, action: #selector(handleComment))
        label.addGestureRecognizer(tg)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        let tg = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        label.addGestureRecognizer(tg)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let photoImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return iv
    }()
    
    private let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
        iv.isUserInteractionEnabled  = true
        return iv
    }()
    
    lazy var repostButton: SpringButton = {
        let button = SpringButton()
        button.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(handleRepost), for: .touchUpInside)
        return button
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "reply"), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    private let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "reply").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    lazy var upvoteButton: SpringButton = {
        let button = SpringButton()
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        button.addTarget(self, action: #selector(handleUpvote), for: .touchUpInside)
        return button
    }()
    
    lazy var downvoteButton: SpringButton = {
        let button = SpringButton()
        button.setImage(#imageLiteral(resourceName: "dislike"), for: .normal)
        button.addTarget(self, action: #selector(handleDownvote), for: .touchUpInside)
        return button
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "bookmarks").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let usernameButton: UIButton = {
        let label = UIButton(type: .system)
        label.setTitleColor(.black, for: .normal)
        label.titleLabel?.lineBreakMode = .byWordWrapping
        label.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        label.contentHorizontalAlignment = .left
        label.addTarget(self, action: #selector(handleUserTap), for: .touchUpInside)
        return label
    }()
    
    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleOptionsTap), for: .touchUpInside)
        return button
    }()

    let votesCounter: UILabel = {
        let label = UILabel()
        let regular = CustomFont.proximaNovaAlt.of(size: 12.0)
        label.font = regular
        label.textColor = .black
        return label
    }()

    var cellId = "homePostCellId"
    
    override func setupViews() {
        super.setupViews()
                
        backgroundColor = .white
        self.layer.cornerRadius = 10
  
        addSubview(userProfileImageView)
        addSubview(optionsButton)
        addSubview(usernameLabel)
        addSubview(captionLabel)
        addSubview(photoImageView)
        addSubview(stackView)
        
        setupConstraints()
    }
    
    // MARK: - Private
    func setupConstraints() {
        // Profile Image
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding, paddingBottom: padding, width: 44, height: 44)
        userProfileImageView.layer.cornerRadius = 44 / 2
        userProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserTap)))
        
        // Name
        usernameLabel.anchor(top: topAnchor, leading: userProfileImageView.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        
        // Options
        optionsButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: padding, left: 0, bottom: padding, right: padding))
        
        // Content
        captionLabel.anchor(top: userProfileImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        
        // Image
        anchorPostImage()
        
        // Buttons
        setupActionButtons()
    }
    
    func anchorPostImage() {
        photoImageView.anchor(top: captionLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        photoImageView.addSubview(heartPopup)
        heartPopup.anchor(widthConstant: 60, heightConstant: 60)
        heartPopup.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
        heartPopup.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
        
        photoImageView.isUserInteractionEnabled = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(imageDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        
        singleTap.require(toFail: doubleTap)
        photoImageView.addGestureRecognizer(singleTap)
        
        photoImageView.addGestureRecognizer(doubleTap)
    }

    let iconSize: CGFloat = 24
    let seperatorView = UIView()
    
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }()
    
    private func setupActionButtons() {
        
        let commentButtonContainer = UIView()
        let upvoteButtonContainer = UIView()
        let downvoteButtonContainer = UIView()
        let repostButtonContainer = UIView()

        seperatorView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        stackView.addArrangedSubview(commentButtonContainer)
        stackView.addArrangedSubview(upvoteButtonContainer)
        stackView.addArrangedSubview(downvoteButtonContainer)
        stackView.addArrangedSubview(repostButtonContainer)
        
        addSubview(seperatorView)
        seperatorView.anchor(nil, left: leftAnchor, bottom: stackView.topAnchor, right: rightAnchor, leftConstant: padding, rightConstant: padding, heightConstant: 1)

        stackView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, bottomConstant: 24, heightConstant: 26)
        
        // Buttons
        addSubview(commentButton)
        commentButton.anchor(commentButtonContainer.topAnchor, bottomConstant: padding, widthConstant: iconSize, heightConstant: iconSize)
        commentButton.centerXAnchor.constraint(equalTo: commentButtonContainer.centerXAnchor).isActive = true
        
        addSubview(upvoteButton)
        upvoteButton.anchor(upvoteButtonContainer.topAnchor, bottomConstant: padding, widthConstant: iconSize, heightConstant: iconSize)
        upvoteButton.centerXAnchor.constraint(equalTo: upvoteButtonContainer.centerXAnchor).isActive = true
        
        addSubview(downvoteButton)
        downvoteButton.anchor(downvoteButtonContainer.topAnchor, bottomConstant: padding, widthConstant: iconSize, heightConstant: iconSize)
        downvoteButton.centerXAnchor.constraint(equalTo: downvoteButtonContainer.centerXAnchor).isActive = true
        
        addSubview(repostButton)
        repostButton.anchor(repostButtonContainer.topAnchor, bottomConstant: padding, widthConstant: iconSize, heightConstant: iconSize)
        repostButton.centerXAnchor.constraint(equalTo: repostButtonContainer.centerXAnchor).isActive = true
        
        //        addSubview(bookmarkButton)
        //        bookmarkButton.anchor(top: stackView.topAnchor, right: rightAnchor, paddingTop: padding, paddingRight: padding)
        
        // Counter
        addSubview(votesCounter)
        votesCounter.anchor(top: seperatorView.bottomAnchor, paddingTop: padding)
        votesCounter.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    
       
    }
    
    fileprivate func setupAttributedCaption(_ post: Post) {
        
        let name = post.user.name
        let username = post.user.username
        guard let nameFont = CustomFont.proximaNovaSemibold.of(size: 14.0) else {return}
        guard let usernameFont = CustomFont.proximaNovaAlt.of(size: 14.0) else {return}
        guard let captionFont = CustomFont.proximaNovaAlt.of(size: 16.0) else {return}
        
        // look for username as pattern
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        // enable username as custom type
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
        
        let nameAttributedText = NSMutableAttributedString(string: (name), attributes: [NSAttributedString.Key.font: nameFont])
        
        let usernameString = "  @\(post.user.username)"
        
        nameAttributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedString.Key.font: usernameFont, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        
        nameAttributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let time = timeAgoDisplay
        
        nameAttributedText.append(NSAttributedString(string: (time), attributes: [NSAttributedString.Key.font: usernameFont, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        
        usernameLabel.attributedText = nameAttributedText
        
        let attributedText = NSMutableAttributedString(string: (post.caption), attributes: [NSAttributedString.Key.font: captionFont])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let range = NSMakeRange(0, attributedText.string.count)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        captionLabel.attributedText = attributedText
    }
    
    func setupCounters(_ post: Post) {
        
        if post.upvotedByCurrentUser {
            votesCounter.textColor = upvoteButton.titleLabel?.textColor
        } else if post.downvotedByCurrentUser {
            votesCounter.textColor = downvoteButton.titleLabel?.textColor
        }
        
        setReposts(to: post.repostCount)
//      setUpvotes(to: post.upvoteCount)
//      setDownvotes(to: post.downvoteCount)
        
        let votes = post.upvoteCount + post.downvoteCount
        setVotes(to: votes)
    }
    
    private func setReposts(to value: Int) {
        var repostsCounter = repostButton.titleLabel?.text
        if value <= 0 {
            repostsCounter = ""
        } else {
            repostsCounter = "\(value)"
        }
    }
    
    private func setUpvotes(to value: Int) {
        var upvotesCounter = upvoteButton.titleLabel?.text
        
        if value <= 0 {
            upvotesCounter = ""
        } else if value >= 1000 {
            upvotesCounter = "\(value/100)k"
        } else {
            upvotesCounter = "\(value)"
        }
    }
    
    private func setDownvotes(to value: Int) {
        var downvotesCounter = downvoteButton.titleLabel?.text
        
        if value >= 0 {
            downvotesCounter = ""
        } else if value >= 1000 {
            downvotesCounter = "\(value/100)k"
        } else {
            downvotesCounter = "\(value)"
        }
    }
    
    private func setVotes(to value: Int) {
        if value >= 1000 {
            votesCounter.text = "\(value/100)k"
        } else {
            votesCounter.text = "\(value)"
        }
        
    }
    
    @objc func handleUpvote() {
        delegate?.didUpvote(for: self)
        self.upvoteButton.animation = "pop"
        self.upvoteButton.curve = "easeIn"
        self.upvoteButton.duration = 0.5
        self.upvoteButton.animate()
    }
    
    @objc func handleDownvote() {
        delegate?.didDownvote(for: self)
        self.downvoteButton.animation = "pop"
        self.downvoteButton.curve = "easeIn"
        self.downvoteButton.duration = 0.5
        self.downvoteButton.animate()
    }
    
    @objc func handleRepost() {
        delegate?.didRepost(for: self)
    }
    
    @objc func handleComment() {
        guard let post = data else { return }
        delegate?.didTapComment(post: post)
    }
    
    @objc private func handleUserTap() {
        guard let post = data else { return }
        delegate?.didTapUser(user: post.user)
    }
    
    @objc private func handleOptionsTap() {
        guard let post = data else { return }
        delegate?.didTapOptions(post: post)
    }
    
    @objc func imageTapped() {
        handleComment()
    }
    
    @objc func imageDoubleTapped()
    {
//        let tappedImage = self.heartPopup
//        (self.controller as? HomeController)?.likeAnimation(tappedImage)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//            (self.controller as? HomeController)?.likeButtonSelected(for: self)
//        })
    }
    
    let heartPopup: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "heart.png")
        iv.alpha = 0
        return iv
    }()
    
}


//MARK: - HomePostCellHeaderDelegate
extension HomePostTextCell: HomePostCellHeaderDelegate {
    
    func didTapUser() {
        guard let post = data else { return }
        let user = post.user
        delegate?.didTapUser(user: user)
    }
    
    func didTapOptions() {
        guard let post = data else { return }
        delegate?.didTapOptions(post: post)
    }
}


extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
