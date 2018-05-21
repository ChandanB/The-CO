//
//  UserProfileTextCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/18/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Kingfisher
import LBTAComponents

protocol UserProfileTextDelegate {
    func didLike(for cell: UserProfileTextCell)
}

class UserProfileTextCell: DatasourceCell {
    
     var delegate: UserProfileTextDelegate?
    
    override var datasourceItem: Any? {
        didSet {
            guard let post = datasourceItem as? Post else { return }
            
            loveButton.setImage(post.hasLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            
            let url = URL(string: post.user.profileImageUrl)
            profileImageView.kf.setImage(with: url)
            
            setupAttibutedCaption(post)
        }
    }
    
    
    fileprivate func setupAttibutedCaption(_ post: Post) {
        
        let name = post.user.name
        let font = CustomFont.proximaNovaSemibold.of(size: 15.0)
        let regular = CustomFont.proximaNovaAlt.of(size: 16.0)
        
        let nameAttributedText = NSMutableAttributedString(string: (name), attributes: [NSAttributedStringKey.font: font!])
        
        let usernameString = " @\(post.user.username)"
        
        nameAttributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedStringKey.font: regular!, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        
        nameAttributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let time = timeAgoDisplay
        
        nameAttributedText.append(NSAttributedString(string: (time), attributes: [NSAttributedStringKey.font: regular!, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        
        nameLabel.attributedText = nameAttributedText
        
        let attributedText = NSMutableAttributedString(string: (post.caption), attributes: [NSAttributedStringKey.font: regular!])
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let range = NSMakeRange(0, attributedText.string.count)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        messageTextView.attributedText = attributedText
        
//        if messageTextView.text == "" {
//            messageTextView.anchor(profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 1)
//        }
    }
    
    let optionsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("•••", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        return tv
    }()
    
    let profileImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var replyButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "reply"), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment() {
      //  guard let post = self.datasourceItem as? Post else { return }
     //   (self.controller as? HomeController)?.didTapComment(post: post)
    }
    
    lazy var upvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        button.addTarget(self, action: #selector(handleUpvote), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUpvote() {
        //   (self.controller as? HomeController)?.didLike(for: self)
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
    
    lazy var loveButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "love"), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        print("Like pressed")
        delegate?.didLike(for: self)
    }
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .white
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(profileImageView)
        addSubview(messageTextView)
        addSubview(optionsButton)
        addSubview(nameLabel)
        
        optionsButton.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 4, rightConstant: 8, widthConstant: 44, heightConstant: 0)
        
        nameLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        messageTextView.anchor(profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 4, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        setupBottomButtons()
        
    }
    
    
    fileprivate func setupBottomButtons() {
        let replyButtonContainerView = UIView()
        let loveButtonContainerView = UIView()
        let upvoteButtonContainerView = UIView()
        let downvoteButtonContainerView = UIView()
        
        let buttonStackView = UIStackView(arrangedSubviews: [replyButtonContainerView, upvoteButtonContainerView, downvoteButtonContainerView, loveButtonContainerView])
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        
        addSubview(buttonStackView)
        
        buttonStackView.anchor(nil, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 26, leftConstant: 4, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 26)
        
        addSubview(replyButton)
        addSubview(upvoteButton)
        addSubview(downvoteButton)
        addSubview(loveButton)
        
        replyButton.anchor(replyButtonContainerView.topAnchor, left: replyButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        upvoteButton.anchor(upvoteButtonContainerView.topAnchor, left: upvoteButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        downvoteButton.anchor(downvoteButtonContainerView.topAnchor, left: downvoteButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        loveButton.anchor(loveButtonContainerView.topAnchor, left: loveButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
    }
    
}
