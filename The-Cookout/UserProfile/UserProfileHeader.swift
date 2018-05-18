//
//  UserProfileHeader.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/17/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class UserProfileHeader: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            guard let user = datasourceItem as? User else { return }
            self.user = user
            setupProfileAndBannerImage()
            usernameLabel.text = user.name
        }
    }
    
    var user: User?

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.layer.cornerRadius = 60
        iv.backgroundColor = .lightGray
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let blurredBannerImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.addBlurEffect()
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.0
        iv.clipsToBounds = true
        return iv
    }()
    
    let blurredImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.addBlurEffect()
        iv.backgroundColor = .blue
        iv.contentMode = .scaleAspectFill
        iv.alpha = 0.0
        iv.clipsToBounds = true
        return iv
    }()
    
    let bannerImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.alpha = 1.0
        iv.clipsToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(bannerImageView)
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(blurredImageView)
        addSubview(blurredBannerImageView)
        
        bannerImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        profileImageView.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 90, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 120)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    fileprivate func setupProfileAndBannerImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        guard let bannerImageUrl = user?.bannerImageUrl else { return }
        
        DispatchQueue.main.async {
            self.profileImageView.loadImage(urlString: profileImageUrl)
            self.bannerImageView.loadImage(urlString: bannerImageUrl)
        }
    }
    
}
