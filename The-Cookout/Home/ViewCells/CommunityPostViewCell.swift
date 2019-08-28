//
//  CommunityPostViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class CommunityPostContentViewCell: HomePostTextCell<CommunityPost> {
    // MARK: - UI Elements
    fileprivate let arrowImage: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "IconArrow").withRenderingMode(.alwaysTemplate))
        image.tintColor = fbDarkGray
        return image
    }()

    fileprivate let communityName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = fbDarkGray
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Overrides
    override func setupViews() {
        super.setupViews()

        addSubview(arrowImage)
        addSubview(communityName)
    }

    override func setupConstraints() {
        super.setupConstraints()

        // Arrow
        arrowImage.anchor(top: topAnchor, leading: usernameLabel.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 7, left: 0, bottom: 0, right: 0))

        // Community Name
        communityName.anchor(top: topAnchor, leading: arrowImage.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 0, bottom: 10, right: 10))
    }

    override func onDataUpdated() {
        super.onDataUpdated()

        communityName.text = data.communityName
    }

    // MARK: - Content Protocol
    override public class func identifier() -> String {
        return "kCommunityPostContentViewCell"
    }
}
