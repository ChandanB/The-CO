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
import FaveButton

class PostCell: DatasourceCell {
        
    override var datasourceItem: Any? {
        didSet {
            guard let post = datasourceItem as? Post else { return }
            setupAttibutedCaption(post)
            
            loveButton.setImage(post.hasLiked == true ? #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            
            if post.hasLiked == true {
                loveButton.tintColor = .red
            } else {
                loveButton.tintColor = .clear
            }
            
            let fetchImage = FetchImage()
            
            fetchImage.fetch(with: post.user.profileImageUrl) { (image) in
                self.profileImageButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        
            let imageUrl = URL(string: post.imageUrl)
            photoImageView.kf.setImage(with: imageUrl)
        }
    }
    
    fileprivate func setupAttibutedCaption(_ post: Post) {
        
        let name = post.user.name
        let font = CustomFont.proximaNovaSemibold.of(size: 14.0)
        let regular = CustomFont.proximaNovaAlt.of(size: 15.0)
        
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
    
    let heartPopup: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "heart.png")
        iv.alpha = 0
        return iv
    }()
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
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
    
    @objc func handleComment() {
        guard let post = self.datasourceItem as? Post else { return }
        (self.controller as? HomeController)?.didTapComment(post: post)
    }
    
    lazy var loveButton: FaveButton = {
        let button = FaveButton()
        button.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        (self.controller as? HomeController)?.faveButton(self.loveButton, didSelected: true)
        (self.controller as? HomeController)?.faveButtonSelected(self.loveButton, didSelected: true, for: self)
    }
    
    lazy var upvoteButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        button.addTarget(self, action: #selector(handleUpvote), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUpvote() {
       // delegate?.didLike(for: self)
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
        
        addSubview(profileImageButton)
        addSubview(messageTextView)
        addSubview(optionsButton)
        addSubview(nameLabel)
        
        optionsButton.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 4, rightConstant: 8, widthConstant: 44, heightConstant: 0)
        
        nameLabel.anchor(profileImageButton.topAnchor, left: profileImageButton.rightAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageButton.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
        
        messageTextView.anchor(profileImageButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 4, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
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
        addSubview(photoImageView)
        photoImageView.addSubview(heartPopup)
        
        buttonStackView.anchor(nil, left: profileImageButton.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 26, leftConstant: 4, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 26)
        
        photoImageView.anchor(messageTextView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        heartPopup.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        heartPopup.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor).isActive = true
        heartPopup.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor).isActive = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognizer.numberOfTapsRequired = 2
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        addSubview(replyButton)
        addSubview(upvoteButton)
        addSubview(downvoteButton)
        addSubview(loveButton)
        
        replyButton.anchor(replyButtonContainerView.topAnchor, left: replyButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        upvoteButton.anchor(upvoteButtonContainerView.topAnchor, left: upvoteButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        downvoteButton.anchor(downvoteButtonContainerView.topAnchor, left: downvoteButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        
        loveButton.anchor(loveButtonContainerView.topAnchor, left: loveButtonContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 0, widthConstant: 20, heightConstant: 20)
    }
    
    @objc func imageTapped()
    {
        let tappedImage = self.heartPopup
         (self.controller as? HomeController)?.faveButtonSelected(self.loveButton, didSelected: true, for: self)
        (self.controller as? HomeController)?.likeAnimation(tappedImage)
    }
    
    
    
}


