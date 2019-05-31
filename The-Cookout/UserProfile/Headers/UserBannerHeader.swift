//
//  UserProfileHeader.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import UIFontComplete
import UIImageColors
import SDWebImage


class UserBannerHeader: DatasourceCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            reloadData()
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
      
        //blur
        setupVisualEffectBlur(true)
    //    setupProfileImage()
  
    }
    
    fileprivate func setupProfileImage() {
        addSubview(profileImageView)
        profileImageView.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: -60, rightConstant: 0, widthConstant: 120, heightConstant: 120)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    
    fileprivate func setupGradientLayer(_ user: User) {
        addSubview(gradientContainerView)
//        gradientContainerView.addSubview(bannerImageView)
//        bannerImageView.frame = self.bounds
//        bannerImageView.frame.origin.y -= bounds.height
        
        guard let colors = self.bannerImageView.image?.getColors() else {return}
        
        gradientLayer.colors = [UIColor.clear.cgColor, colors.primary.cgColor]
        gradientLayer.locations = [0, 1]
        
        gradientContainerView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        gradientContainerView.layer.addSublayer(gradientLayer)
        
        gradientLayer.frame = self.bounds
        gradientLayer.frame.origin.y -= bounds.height
        
        let heavyLabel = UILabel()
        heavyLabel.text = ""
        heavyLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        heavyLabel.textColor = .white

        let descriptionLabel = UILabel()
        descriptionLabel.text = "\(user.name)"
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [heavyLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 6, right: 12))
        
       
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
                print("true")
            case false:
                print("false")
            }
        })
    }
    
    func reloadData() {
        guard let user = user else { return }
        setupProfileAndBannerImage(user)
    }
    
    
    fileprivate func setupProfileAndBannerImage(_ user: User) {
        
        let url = URL(string: user.bannerImageUrl)
        bannerImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        bannerImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            self.setupGradientLayer(user)
        }
    }
    
}
