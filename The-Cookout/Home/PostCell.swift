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
import Kingfisher

protocol UserPostCellDelegate {
    func didLike(for cell: PostCell)
    func didTapComment(post: Post)
}

class PostCell: DatasourceCell {
    
    var delegate: UserPostCellDelegate?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var post: Post?

    override var datasourceItem: Any? {
        didSet {
            guard let post = datasourceItem as? Post else { return }
            let url = post.user.profileImageUrl
            self.post = post

            updateView(post)
            setupAttibutedCaption(post)
            
            let fetchImage = FetchImage()
            
            DispatchQueue.main.async {
                fetchImage.fetch(with: url) { (image) in
                    self.profileImageButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
    
        }
    }
    
    
    fileprivate func setupAttibutedCaption(_ post: Post) {
        
        let name = post.user.name
        let font = CustomFont.proximaNovaSemibold.of(size: 11.0)
        let regular = CustomFont.proximaNovaAlt.of(size: 14.0)
        
        let nameAttributedText = NSMutableAttributedString(string: (name), attributes: [NSAttributedString.Key.font: font!])
        
        let usernameString = "  @\(post.user.username)"
        
        nameAttributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedString.Key.font: regular!, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        
        nameAttributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
                
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let time = timeAgoDisplay
        
        nameAttributedText.append(NSAttributedString(string: (time), attributes: [NSAttributedString.Key.font: regular!, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        
        nameLabel.attributedText = nameAttributedText
        
        let attributedText = NSMutableAttributedString(string: (post.caption), attributes: [NSAttributedString.Key.font: regular!])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let range = NSMakeRange(0, attributedText.string.count)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        messageTextView.attributedText = attributedText
        
    }
    
    let optionsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    let photoImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        return iv
    }()
    
    let heartPopup: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "heart.png")
        iv.alpha = 0
      //  iv.isSkeletonable = true
        return iv
    }()
    
    lazy var messageTextView: UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        let tg = UITapGestureRecognizer(target: self, action: #selector(handleComment))
        tv.addGestureRecognizer(tg)
        tv.isUserInteractionEnabled = true
     //   tv.isSkeletonable = true
        return tv
    }()
    
    lazy var profileImageButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleUserProfile), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUserProfile() {
        print("DId tap picture")
        (self.controller as? HomeController)?.didTapProfilePicture(for: self)
    }
    
    lazy var replyButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "reply"), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let repliesCount: UILabel = {
        let label = UILabel()
        let regular = CustomFont.proximaNovaAlt.of(size: 10.0)
        label.font = regular
        label.text = "0"
        return label
    }()
    
    @objc func handleComment() {
        guard let post = self.datasourceItem as? Post else { return }
        delegate?.didTapComment(post: post)
        (self.controller as? HomeController)?.didTapComment(post: post)
    }
    
    lazy var likeButton: SpringButton = {
        let button = SpringButton()
        button.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    let likesCount: UILabel = {
        let label = UILabel()
        let regular = CustomFont.proximaNovaAlt.of(size: 10.0)
        label.font = regular
        label.text = "Like"
        return label
    }()
    
    @objc func handleLike() {
        delegate?.didLike(for: self)
        (self.controller as? HomeController)?.likeButtonSelected(for: self)
    }
    
    lazy var upvoteButton: SpringButton = {
        let button = SpringButton()
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        
        button.addTarget(self, action: #selector(handleUpvote), for: .touchUpInside)
        return button
    }()
    
    let votesCount: UILabel = {
        let label = UILabel()
        let regular = CustomFont.proximaNovaAlt.of(size: 10.0)
        label.font = regular
        label.text = "0"
        return label
    }()
    
    @objc func handleUpvote() {
        self.upvoteButton.animation = "pop"
        self.upvoteButton.curve = "easeIn"
        self.upvoteButton.duration = 0.5
        self.upvoteButton.animate()
    }
    
    lazy var downvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "dislike"), for: .normal)
        button.addTarget(self, action: #selector(handleDownvote), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDownvote() {
        //   (self.controller as? HomeController)?.didLike(for: self)
    }
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        let tg = UITapGestureRecognizer(target: self, action: #selector(handleUserProfile))
        label.addGestureRecognizer(tg)
        label.isUserInteractionEnabled = true
    //    label.isSkeletonable = true
        return label
    }()
    
    func updateView(_ post: Post) {
        
        let imageUrl = URL(string: post.imageUrl)
        self.photoImageView.kf.setImage(with: imageUrl)
        
        messageTextView.anchor(profileImageButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 4, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        setupBottomButtons(post)
        
        likeButton.setImage(post.hasLiked == true ? #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        self.likesCount.text = String(post.likeCount)
        
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.layer.cornerRadius = 10
        
        backgroundColor = .white
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(profileImageButton)
        addSubview(messageTextView)
        addSubview(optionsButton)
        addSubview(nameLabel)
                
        optionsButton.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 4, rightConstant: 12, widthConstant: 44, heightConstant: 0)
        
        nameLabel.anchor(profileImageButton.topAnchor, left: profileImageButton.rightAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageButton.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
        
    }

    
    fileprivate func setupBottomButtons(_ post: Post) {
    
        let replyButtonContainerView = UIView()
        let likeButtonContainerView = UIView()
        let upvoteButtonContainerView = UIView()
        let downvoteButtonContainerView = UIView()
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        let buttonStackView = UIStackView(arrangedSubviews: [replyButtonContainerView, upvoteButtonContainerView, downvoteButtonContainerView, likeButtonContainerView])
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        
        addSubview(seperatorView)
        addSubview(buttonStackView)
        
        if post.hasImage {
            addSubview(photoImageView)
            photoImageView.addSubview(heartPopup)
            
            photoImageView.anchor(messageTextView.bottomAnchor, left: nil, bottom: seperatorView.topAnchor, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: bounds.width - 30, heightConstant: 0)
            photoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            heartPopup.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
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
        
        seperatorView.anchor(nil, left: self.leftAnchor, bottom: buttonStackView.topAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 8, rightConstant: 12, widthConstant: 0, heightConstant: 1)
        
        buttonStackView.anchor(nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 34, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 26)
        buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        
        addSubview(replyButton)
        addSubview(repliesCount)
        
        addSubview(upvoteButton)
        addSubview(votesCount)
        addSubview(downvoteButton)
        
        addSubview(likeButton)
        addSubview(likesCount)
        
        replyButton.anchor(replyButtonContainerView.topAnchor, left: replyButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        repliesCount.anchor(replyButtonContainerView.topAnchor, left: replyButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 10, rightConstant: 0, widthConstant: 70, heightConstant: 20)
        
        upvoteButton.anchor(upvoteButtonContainerView.topAnchor, left: nil, bottom: nil, right: upvoteButtonContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 35, widthConstant: 20, heightConstant: 20)
        downvoteButton.anchor(downvoteButtonContainerView.topAnchor, left: downvoteButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        votesCount.anchor(upvoteButtonContainerView.topAnchor, left: nil, bottom: nil, right: upvoteButtonContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        likeButton.anchor(likeButtonContainerView.topAnchor, left: likeButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        likesCount.anchor(likeButtonContainerView.topAnchor, left: likeButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 6, bottomConstant: 10, rightConstant: 0, widthConstant: 40, heightConstant: 20)
    }
    
    @objc func imageTapped() {
        handleComment()
    }
    
    @objc func imageDoubleTapped()
    {
        let tappedImage = self.heartPopup
        (self.controller as? HomeController)?.likeAnimation(tappedImage)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            (self.controller as? HomeController)?.likeButtonSelected(for: self)
        })
    }
    
}


