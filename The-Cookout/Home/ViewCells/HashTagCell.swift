//
//  HashTagCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/7/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class HashtagCell: UICollectionViewCell {

    // MARK: - Properties

    var post: Post? {

        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            let url = URL(string: imageUrl)
            postImageView.sd_setImage(with: url, completed: nil)
        }
    }

    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
