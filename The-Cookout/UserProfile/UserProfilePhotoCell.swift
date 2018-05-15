//
//  UserProfilePhotoCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/15/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            setupProfileImage()
        }
    }
    
    let photoImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupProfileImage() {
        guard let url = post?.imageUrl else { return }
        self.photoImageView.loadImage(urlString: url)
        DispatchQueue.main.async {
            self.photoImageView.loadImage(urlString: url)
        }
    }
    
}
