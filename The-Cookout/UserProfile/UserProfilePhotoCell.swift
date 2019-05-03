//
//  UserProfilePhotoCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/15/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Kingfisher
import LBTAComponents
import PinterestLayout

protocol PhotoCellDelegate {
    func presentLightBox(for cell: UserProfilePhotoCell)
    func didTapImage(_ post: Post)
}

class UserProfilePhotoCell: DatasourceCell {
    
    var delegate: PhotoCellDelegate?
    static var cellId = "userProfilePhotoGridCellId"

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
            //change image view height by changing its constraint
            photoImageView.heightAnchor.constraint(equalToConstant: attributes.imageHeight).isActive = true
        }
    }
    
    var post: Post?
    override var datasourceItem: Any? {
        didSet {
            guard let post = datasourceItem as? Post else { return }
            self.post = post
            let url = URL(string: post.imageUrl)
            photoImageView.kf.setImage(with: url)
        }
    }
    
    lazy var photoImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        let tg = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        iv.addGestureRecognizer(tg)
        return iv
    }()
    
    @objc func imageTapped() {
      guard let image = self.post else {return}
      delegate?.didTapImage(image)
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(photoImageView)
        photoImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
}
