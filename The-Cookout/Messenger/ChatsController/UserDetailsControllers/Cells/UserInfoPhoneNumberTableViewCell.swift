//
//  UserInfoPhoneNumberTableViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import ARSLineProgress

extension UIViewController {

}

class UserInfoUsernameTableViewCell: UITableViewCell {

  weak var userInfoTableViewController: UserInfoTableViewController?

  let copyNumberImage = UIImage(named: "copyNumber")?.withRenderingMode(.alwaysTemplate)

  let copy: UIButton = {
    let copy = UIButton(type: .system)
    copy.translatesAutoresizingMaskIntoConstraints = false
    copy.imageView?.contentMode = .scaleAspectFit

    return copy
  }()

  let add: UIButton = {
    let add = UIButton(type: .system )
    add.translatesAutoresizingMaskIntoConstraints = false
    add.imageView?.contentMode = .scaleAspectFit
    add.setTitle("Follow user", for: .normal)

    return add
  }()

  let phoneLabel: UILabel = {
    let phoneLabel = UILabel()
    phoneLabel.sizeToFit()
    phoneLabel.textColor = ThemeManager.currentTheme().generalTitleColor
    phoneLabel.translatesAutoresizingMaskIntoConstraints = false

    return phoneLabel
  }()

  let contactStatus: UILabel = {
    let contactStatus = UILabel()
    contactStatus.sizeToFit()
    contactStatus.font = UIFont.systemFont(ofSize: 12)
    contactStatus.text = "You do not follow this user"
    contactStatus.textColor = ThemeManager.currentTheme().generalSubtitleColor
    contactStatus.translatesAutoresizingMaskIntoConstraints = false

    return contactStatus
  }()

  let bio: UILabel = {
    let bio = UILabel()
    bio.sizeToFit()
    bio.numberOfLines = 0
    bio.textColor = ThemeManager.currentTheme().generalTitleColor
    bio.translatesAutoresizingMaskIntoConstraints = false
    bio.font = UIFont.systemFont(ofSize: 17)

    return bio
  }()

  var bioTopAnchor: NSLayoutConstraint!

  var addHeightConstraint: NSLayoutConstraint!
   var phoneTopConstraint: NSLayoutConstraint!
  var contactStatusHeightConstraint: NSLayoutConstraint!

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    addSubview(copy)
    addSubview(add)
    addSubview(contactStatus)
    addSubview(phoneLabel)
    addSubview(bio)

    contactStatus.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
    if #available(iOS 11.0, *) {
      contactStatus.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
    } else {
        contactStatus.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
    }
    contactStatus.widthAnchor.constraint(equalToConstant: 180).isActive = true
    contactStatusHeightConstraint = contactStatus.heightAnchor.constraint(equalToConstant: 40)
    contactStatusHeightConstraint.isActive = true

    phoneTopConstraint = phoneLabel.topAnchor.constraint(equalTo: contactStatus.bottomAnchor, constant: 0)
    phoneTopConstraint.isActive = true

    if #available(iOS 11.0, *) {
      phoneLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
    } else {
       phoneLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
    }
    phoneLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
    phoneLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

    if #available(iOS 11.0, *) {
      copy.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
      add.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
    } else {
      copy.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
      add.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }

    add.widthAnchor.constraint(equalToConstant: 110).isActive = true
    addHeightConstraint = add.heightAnchor.constraint(equalToConstant: 20)
    addHeightConstraint.isActive = true
    add.centerYAnchor.constraint(equalTo: contactStatus.centerYAnchor, constant: 0).isActive = true

    copy.widthAnchor.constraint(equalToConstant: 20).isActive = true
    copy.heightAnchor.constraint(equalToConstant: 20).isActive = true
    copy.centerYAnchor.constraint(equalTo: phoneLabel.centerYAnchor, constant: 0).isActive = true

    add.addTarget(self, action: #selector(handleAddNewContact), for: .touchUpInside)
    copy.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
    copy.setImage(copyNumberImage, for: .normal)

    bioTopAnchor = bio.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 20)
    bioTopAnchor.isActive = true
    if #available(iOS 11.0, *) {
      bio.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
      bio.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
    } else {
      bio.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
      bio.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
     copy.imageView?.image = nil
  }

  @objc func handleAddNewContact() {
  }

  @objc func handleCopy() {
     UIPasteboard.general.string = self.phoneLabel.text
     ARSLineProgress.showSuccess()
  }
}
