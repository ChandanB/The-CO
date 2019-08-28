//
//  UserSearchCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/16/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents

class UserSearchCell: DatasourceCell {

    override var datasourceItem: Any? {
        didSet {
            guard let user = datasourceItem as? User else { return }
            configureCell(user)
        }
    }

    let profileImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()

    override func setupViews() {
        super.setupViews()
        backgroundColor = .white

        addSubview(profileImageView)
        addSubview(nameLabel)

        profileImageView.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        nameLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: -8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)

    }

    func configureCell(_ user: User) {

        let url = URL(string: user.profileImageUrl)
        profileImageView.sd_setImage(with: url, completed: nil)

        let nameAttributedText = NSMutableAttributedString(string: (user.name), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        let usernameString = "@\(user.username)"

        nameAttributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 5)]))
        nameAttributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray]))

        nameLabel.attributedText = nameAttributedText
    }

}
