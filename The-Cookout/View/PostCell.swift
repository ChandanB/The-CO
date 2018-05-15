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
            
            let url = URL(string: post.profileImageUrl)
            profileImageView.kf.setImage(with: url)

            let attributedText = NSMutableAttributedString(string: (post.name), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
            
            let usernameString = "  \(post.username)\n"
            attributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.gray]))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let range = NSMakeRange(0, attributedText.string.count)
            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

            attributedText.append(NSAttributedString(string: post.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]))
            
            messageTextView.attributedText = attributedText
            
        }
    }
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "profile_image")
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

    let repostButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "repost"), for: .normal)
        
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .white
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(profileImageView)
        addSubview(messageTextView)
    
        
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
        messageTextView.anchor(topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 4, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        setupBottomButtons()
        
    }
    
    fileprivate func setupBottomButtons() {
        let replyButtonContainerView = UIView()
        let repostButtonContainerView = UIView()
        let likeButtonContainerView = UIView()
        let dislikeButtonContainerView = UIView()
        
        let buttonStackView = UIStackView(arrangedSubviews: [replyButtonContainerView, likeButtonContainerView, dislikeButtonContainerView, repostButtonContainerView])
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        
        addSubview(buttonStackView)
        buttonStackView.anchor(nil, left: messageTextView.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 2, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
        addSubview(replyButton)
        addSubview(likeButton)
        addSubview(dislikeButton)
        addSubview(repostButton)
        
        replyButton.anchor(replyButtonContainerView.topAnchor, left: replyButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        likeButton.anchor(likeButtonContainerView.topAnchor, left: likeButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        dislikeButton.anchor(dislikeButtonContainerView.topAnchor, left: dislikeButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        repostButton.anchor(repostButtonContainerView.topAnchor, left: repostButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
    }

}
