//
//  HomePostCellHeader.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/2/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

protocol HomePostCellHeaderDelegate {
    func didTapUser()
    func didTapOptions()
}

class HomePostCellHeader: UIView {

    var post: Post? {
        didSet {
            configureUser()
        }
    }

    private var padding: CGFloat = 8

    var delegate: HomePostCellHeaderDelegate?

    fileprivate func setupAttibutedUsername() {
        guard let post = self.post else {return}

        let name = post.user.name
        let username = post.user.username
        guard let font = CustomFont.proximaNovaSemibold.of(size: 11.0) else {return}
        guard let regular = CustomFont.proximaNovaAlt.of(size: 14.0) else {return}

        let nameAttributedText = NSMutableAttributedString(string: (name), attributes: [NSAttributedString.Key.font: font])
        let usernameString = "  @\(username)"
        nameAttributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedString.Key.font: regular, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))
        nameAttributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))

        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let time = timeAgoDisplay

        let mySelectedAttributedTitle = NSAttributedString(string: (time),
                                                           attributes: [NSAttributedString.Key.font: regular, .foregroundColor: UIColor(r: 100, g: 100, b: 100)])
        usernameButton.setAttributedTitle(mySelectedAttributedTitle, for: .normal)
        usernameButton.setAttributedTitle(mySelectedAttributedTitle, for: .selected)
    }

    private let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
        iv.isUserInteractionEnabled  = true
        return iv
    }()

    private let usernameButton: UIButton = {
        let label = UIButton(type: .system)
        label.setTitleColor(.black, for: .normal)
        label.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        label.contentHorizontalAlignment = .left
        label.addTarget(self, action: #selector(handleUserTap), for: .touchUpInside)
        return label
    }()

    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleOptionsTap), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    private func sharedInit() {
        addSubview(userProfileImageView)
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, paddingTop: padding, paddingLeft: padding, paddingBottom: padding, width: 44, height: 44)
        userProfileImageView.layer.cornerRadius = 44 / 2
        userProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserTap)))

        addSubview(optionsButton)
        optionsButton.anchor(top: topAnchor, bottom: nil, right: rightAnchor, paddingRight: padding, width: 44)

        addSubview(usernameButton)
        usernameButton.anchor(userProfileImageView.topAnchor, left: userProfileImageView.rightAnchor, topConstant: 4, leftConstant: 12)
    }

    private func configureUser() {
        guard let post = post else { return }
        let url = URL(string: post.user.profileImageUrl)
        userProfileImageView.sd_setImage(with: url, completed: nil)
        setupAttibutedUsername()
    }

    @objc private func handleUserTap() {
        delegate?.didTapUser()
    }

    @objc private func handleOptionsTap() {
        delegate?.didTapOptions()
    }
}
