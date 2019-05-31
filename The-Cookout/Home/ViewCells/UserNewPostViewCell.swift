//
//  UserNewPostViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class UserNewPostViewCell: UICollectionReusableView, ContentViewCell {
    // MARK: - UI Elements
    fileprivate let profileImage: UIImageView = {
        let image = UIImageView()
        image.sd_setImage(with: URL(string: ""))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 20
        return image
    }()
    
    fileprivate let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add a post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = fbGray
        
        return button
    }()
    
    fileprivate let stackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = UIStackView.Distribution.fillEqually
        stack.alignment = UIStackView.Alignment.center
        stack.axis = .horizontal
        
        // Live Button
        let liveButton = UIButton(withImage: #imageLiteral(resourceName: "microphone"), title: "Live")
        
        // Photo Button
        let photoButton = UIButton(withImage: #imageLiteral(resourceName: "CameraOverlayView-CameraFlip"), title: "Photo")
        
        // Check In Button
        let checkInButton = UIButton(withImage: #imageLiteral(resourceName: "home_unselected"), title: "Check In")
        
        stack.addArrangedSubview(liveButton)
        stack.addArrangedSubview(photoButton)
        stack.addArrangedSubview(checkInButton)
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        // Add UI Elements
        addSubview(profileImage)
        addSubview(addButton)
        addSubview(stackView)
        
        // Setup Constraints
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    fileprivate func setupConstraints() {
        
        profileImage.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.anchor(top: topAnchor, leading: profileImage.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        addButton.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true
        
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 10, left: 10, bottom: 8, right: 10))
    }
    
    // MARK: - ContentViewCellProtocol
    public class func identifier() -> String {
        return "kUserNrePostVirewCell"
    }
}
