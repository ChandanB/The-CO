//
//  PostCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class PostCell: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            guard let post = datasourceItem as? Post else { return }
            
            let url = URL(string: post.user.profileImageUrl)
            profileImageView.kf.setImage(with: url)
            
            let imageUrl = URL(string: post.imageUrl)
            photoImageView.kf.setImage(with: imageUrl)
            
            let nameAttributedText = NSMutableAttributedString(string: (post.user.name), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)])
            
            let usernameString = "  @\(post.user.username)"
            
            nameAttributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.gray]))
            
            nameAttributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
            
//            nameAttributedText.append(NSAttributedString(string: (time), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.lightGray]))
            
            nameLabel.attributedText = nameAttributedText
            
            let attributedText = NSMutableAttributedString(string: (post.caption), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)])
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let range = NSMakeRange(0, attributedText.string.count)
            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
            messageTextView.attributedText = attributedText
            
        }
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
        return iv
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
    
    let replyButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "reply"), for: .normal)
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        return button
    }()
    
    let dislikeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "dislike"), for: .normal)
        
        return button
    }()
    
    let loveButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "love"), for: .normal)
        
        return button
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
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
        let likeButtonContainerView = UIView()
        let dislikeButtonContainerView = UIView()
        
        let buttonStackView = UIStackView(arrangedSubviews: [replyButtonContainerView, likeButtonContainerView, dislikeButtonContainerView, loveButtonContainerView])
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        
        addSubview(buttonStackView)
        addSubview(photoImageView)
        
        buttonStackView.anchor(nil, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 26, leftConstant: 4, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 26)
        
        photoImageView.anchor(messageTextView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        addSubview(replyButton)
        addSubview(likeButton)
        addSubview(dislikeButton)
        addSubview(loveButton)
        
        replyButton.anchor(replyButtonContainerView.topAnchor, left: replyButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        likeButton.anchor(likeButtonContainerView.topAnchor, left: likeButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        dislikeButton.anchor(dislikeButtonContainerView.topAnchor, left: dislikeButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        loveButton.anchor(loveButtonContainerView.topAnchor, left: loveButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
    }
    
}
