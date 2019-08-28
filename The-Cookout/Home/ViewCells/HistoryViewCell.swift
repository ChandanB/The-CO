//
//  HistoryViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import SDWebImage

class HistoryViewCell: UICollectionViewCell {
    // MARK: - Properties
    var content: History! {
        didSet {
            // Set the Name
            nameLabel.text = content.isSelfPost ? "Add to Story" : content.name

            // Set the Cover
            let imgUrl = content.histories.count > 0 ? content.histories[0] : content.profileUrl
            coverImage.sd_setImage(with: URL(string: imgUrl))

            // Set the profile Pic
            if !content.isSelfPost {
                profileImage.sd_setImage(with: URL(string: content.profileUrl))
                profileImage.layer.borderWidth = 2
                profileImage.layer.borderColor = fbBlueLight.cgColor
            } else {
                profileImage.image = #imageLiteral(resourceName: "IconAdd").withRenderingMode(.alwaysTemplate)
                profileImage.tintColor = fbBlueLight
                profileImage.backgroundColor = .white
                profileImage.contentMode = .center
            }
        }
    }

    // MARK: - UI Elements
    fileprivate let profileImage: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        image.clipsToBounds = true
        image.layer.cornerRadius = 15
        image.contentMode = .scaleAspectFill
        return image
    }()

    fileprivate let coverImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()

    fileprivate let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 0
        label.withShadow()
        return label
    }()

    fileprivate var profileView: UIView!

    // MARK: - Override
    override init(frame: CGRect) {
        super.init(frame: frame)

        // View Setups
        clipsToBounds = true
        layer.cornerRadius = 10

        // Add UI Elements
        profileView = UIView(frame: .init(x: 0, y: 0, width: 40, height: 40))
        profileView.addSubview(profileImage)

        addSubview(coverImage)
        addSubview(profileView)
        addSubview(nameLabel)

        // Setup Contraints
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    fileprivate func setupConstraints() {
        coverImage.fillSuperview()

        profileView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 8, bottom: 0, right: 0))
        nameLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 10, bottom: 10, right: 10))
    }
}
