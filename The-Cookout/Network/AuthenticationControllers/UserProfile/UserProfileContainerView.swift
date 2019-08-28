//
//  UserProfileContainerView.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

class BioTextView: UITextView {
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(UIResponderStandardEditActions.paste(_:)) {
      return false
    }
    return super.canPerformAction(action, withSender: sender)
  }
}

class PasteRestrictedTextField: UITextField {
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(UIResponderStandardEditActions.paste(_:)) {
      return false
    }
    return super.canPerformAction(action, withSender: sender)
  }
}

class UserProfileContainerView: UIView {

  lazy var profileImageView: UIImageView = {
    let profileImageView = UIImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.masksToBounds = true
    profileImageView.layer.borderWidth = 1
    profileImageView.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
    profileImageView.layer.cornerRadius = 48
    profileImageView.isUserInteractionEnabled = true

    return profileImageView
  }()

  let addPhotoLabel: UILabel = {
    let addPhotoLabel = UILabel()
    addPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
    addPhotoLabel.text = "Add\nphoto"
    addPhotoLabel.numberOfLines = 2
    addPhotoLabel.textColor = SocialPointPalette.defaultBlue
    addPhotoLabel.textAlignment = .center

    return addPhotoLabel
  }()

  var name: PasteRestrictedTextField = {
    let name = PasteRestrictedTextField()
    name.font = UIFont.systemFont(ofSize: 20)
    name.enablesReturnKeyAutomatically = true
    name.translatesAutoresizingMaskIntoConstraints = false
    name.textAlignment = .center
    name.placeholder = "Enter name"
    name.borderStyle = .none
    name.autocorrectionType = .no
    name.returnKeyType = .done
    name.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    name.textColor = ThemeManager.currentTheme().generalTitleColor

    return name
  }()

  let username: PasteRestrictedTextField = {
    let username = PasteRestrictedTextField()
    username.font = UIFont.systemFont(ofSize: 20)
    username.translatesAutoresizingMaskIntoConstraints = false
    username.textAlignment = .center
    username.keyboardType = .numberPad
    username.placeholder = "Username"
    username.borderStyle = .none
    username.isEnabled = false
    username.textColor = ThemeManager.currentTheme().generalSubtitleColor
    username.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance

    return username
  }()

  let bioPlaceholderLabel: UILabel = {
    let bioPlaceholderLabel = UILabel()
    bioPlaceholderLabel.text = "Bio"
    bioPlaceholderLabel.sizeToFit()
    bioPlaceholderLabel.textAlignment = .center
    bioPlaceholderLabel.backgroundColor = .clear
    bioPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
    bioPlaceholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor

    return bioPlaceholderLabel
  }()

  let userData: UIView = {
    let userData = UIView()
    userData.translatesAutoresizingMaskIntoConstraints = false
    userData.layer.cornerRadius = 30
    userData.layer.borderWidth = 1
    userData.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor

    return userData
  }()

  let bio: BioTextView = {
    let bio = BioTextView()
    bio.translatesAutoresizingMaskIntoConstraints = false
    bio.layer.cornerRadius = 28
    bio.layer.borderWidth = 1
    bio.textAlignment = .center
    bio.font = UIFont.systemFont(ofSize: 16)
    bio.isScrollEnabled = false
    bio.textContainerInset = UIEdgeInsets(top: 15, left: 35, bottom: 15, right: 35)
    bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    bio.backgroundColor = .clear
    bio.textColor = ThemeManager.currentTheme().generalTitleColor
    bio.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
    bio.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
    bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    bio.textContainer.lineBreakMode = .byTruncatingTail
    bio.returnKeyType = .done

    return bio
  }()

  let countLabel: UILabel = {
    let countLabel = UILabel()
    countLabel.translatesAutoresizingMaskIntoConstraints = false
    countLabel.sizeToFit()
    countLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
    countLabel.isHidden = true

    return countLabel
  }()

  let bioMaxCharactersCount = 70

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = ThemeManager.currentTheme().generalBackgroundColor

    addSubview(addPhotoLabel)
    addSubview(profileImageView)
    addSubview(userData)
    addSubview(bio)
    addSubview(countLabel)
    userData.addSubview(name)
    userData.addSubview(username)
    bio.addSubview(bioPlaceholderLabel)

    profileImageView.anchor(top: topAnchor, paddingTop: 30, width: 100, height: 100)
    userData.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0)
    name.anchor(top: userData.topAnchor, left: userData.leftAnchor, right: userData.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 50)
    username.anchor(top: name.bottomAnchor, left: userData.leftAnchor, right: userData.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 50)
      NSLayoutConstraint.activate([

        addPhotoLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
        addPhotoLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
        addPhotoLabel.widthAnchor.constraint(equalToConstant: 100),
        addPhotoLabel.heightAnchor.constraint(equalToConstant: 100),

        bio.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),

        countLabel.widthAnchor.constraint(equalToConstant: 30),
        countLabel.heightAnchor.constraint(equalToConstant: 30),
        countLabel.rightAnchor.constraint(equalTo: bio.rightAnchor, constant: -5),
        countLabel.bottomAnchor.constraint(equalTo: bio.bottomAnchor, constant: -5),

        bioPlaceholderLabel.centerXAnchor.constraint(equalTo: bio.centerXAnchor, constant: 0),
        bioPlaceholderLabel.centerYAnchor.constraint(equalTo: bio.centerYAnchor, constant: 0)
      ])

    bioPlaceholderLabel.font = UIFont.systemFont(ofSize: 20)//(bio.font!.pointSize - 1)
    bioPlaceholderLabel.isHidden = !bio.text.isEmpty

    if #available(iOS 11.0, *) {
      NSLayoutConstraint.activate([
        profileImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
        bio.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
        bio.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
        userData.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
      ])
    } else {
      NSLayoutConstraint.activate([
        profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        bio.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
        bio.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        userData.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
      ])
    }
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
}
