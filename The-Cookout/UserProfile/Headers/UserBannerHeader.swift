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

class UserBannerHeader: DatasourceCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            setupProfileAndBannerImage()
        }
    }
    
    static var cellId = "userBannerHeaderCellId"
    
    let bannerImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.backgroundColor = twitterBlue
        iv.contentMode = .scaleAspectFill
        iv.alpha = 1.0
        iv.clipsToBounds = true
        return iv
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
    
    let gradientLayer = CAGradientLayer()
    let gradientContainerView = UIView()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bannerImageView)
        bannerImageView.fillSuperview()
        bannerImageView.frame.origin.y -= bounds.height
        
        setupGradientLayer()
      
        //blur
        setupVisualEffectBlur(true)
     //   setupProfileImage()
  
    }
    
    fileprivate func setupProfileImage() {
        addSubview(profileImageView)
        profileImageView.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: -60, rightConstant: 0, widthConstant: 120, heightConstant: 120)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    
    fileprivate func setupGradientLayer() {
        addSubview(gradientContainerView)
//        gradientContainerView.addSubview(bannerImageView)
//        bannerImageView.frame = self.bounds
//        bannerImageView.frame.origin.y -= bounds.height
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.3, 1]
        
        gradientContainerView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        gradientContainerView.layer.addSublayer(gradientLayer)
        
        gradientLayer.frame = self.bounds
        gradientLayer.frame.origin.y -= bounds.height
        
        let heavyLabel = UILabel()
        heavyLabel.text = "Chandan Brown"
        heavyLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        heavyLabel.textColor = .white

        let descriptionLabel = UILabel()
        descriptionLabel.text = "DAB ON EM"
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [
            heavyLabel, descriptionLabel
            ])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
       
    }
    
    var animator: UIViewPropertyAnimator!
    
    fileprivate func setupVisualEffectBlur(_ enable: Bool) {
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: { [weak self] in
            let blurEffect = UIBlurEffect(style: .dark)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            self?.bannerImageView.addSubview(visualEffectView)
            visualEffectView.fillSuperview()

            let enabled = visualEffectView.effect != nil
            guard enable != enabled else { return }
            switch enable {
            case true:
                visualEffectView.pauseAnimation(delay: 0.3)
            case false:
                visualEffectView.resumeAnimation()
                visualEffectView.effect = nil
            }
        })
        
      //  animator.fractionComplete = 0
    }
    
    
    fileprivate func setupProfileAndBannerImage() {
     //   guard let profileImageUrl = user?.profileImageUrl else { return }
        guard let bannerImageUrl = user?.bannerImageUrl else { return }
        
        DispatchQueue.main.async {
     //       self.profileImageView.loadImage(urlString: profileImageUrl)
            self.bannerImageView.loadImage(urlString: bannerImageUrl)
        }
    }
    
}
