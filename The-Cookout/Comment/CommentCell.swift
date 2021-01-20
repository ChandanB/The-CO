//
//  CommentCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/18/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import SDWebImage

class CommentCell: DatasourceCell {

    static var cellId = "commentCellId"

    override var datasourceItem: Any? {
        didSet {
            guard let comment = datasourceItem as? Comment else { return }
            configureComment(comment)
        }
    }

    var delegate: CommentCellDelegate?

    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        return textView
    }()

    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()

    override func setupViews() {
        super.setupViews()
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)

        addSubview(profileImageView)
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        addSubview(textView)
        textView.anchor(topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 4, leftConstant: 4, bottomConstant: 4, rightConstant: 4, widthConstant: 0, heightConstant: 0)
    }

    private func configureComment(_ comment: Comment) {
        setupAttributedText(comment)

        profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray

        let url = URL(string: comment.user.profileImageUrl)
        profileImageView.sd_setImage(with: url, completed: nil)

    }

    fileprivate func setupAttributedText(_ comment: Comment) {
        let name = comment.user.name
        let username = comment.user.username

        let font = CustomFont.proximaNovaSemibold.of(size: 15.0)!
        let regular = CustomFont.proximaNovaAlt.of(size: 16.0)!
        let timeFont = CustomFont.proximaNovaAlt.of(size: 12.0)!

        let timeAgoDisplay = comment.creationDate.timeAgoDisplay()
        let time = timeAgoDisplay

        let attributedText = NSMutableAttributedString(string: (name), attributes: [NSAttributedString.Key.font: font])

        let usernameString = " @\(username)"

        attributedText.append(NSAttributedString(string: usernameString, attributes: [NSAttributedString.Key.font: regular, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))

        attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: comment.text, attributes: [NSAttributedString.Key.font: regular]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: (time), attributes: [NSAttributedString.Key.font: timeFont, .foregroundColor: UIColor(r: 100, g: 100, b: 100)]))

        textView.attributedText = attributedText
    }

    @objc private func handleTap() {
        guard let comment = datasourceItem as? Comment else { return }
        let user = comment.user
        delegate?.didTapUser(user: user)
    }

}
