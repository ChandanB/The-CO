//
//  InformationMessageCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class InformationMessageCell: RevealableCollectionViewCell {

  let information: UILabel = {
    let information = UILabel()
    information.font = UIFont.systemFont(ofSize: 12)
    information.numberOfLines = 0
    information.textAlignment = .center
    information.textColor = ThemeManager.currentTheme().generalSubtitleColor
    information.translatesAutoresizingMaskIntoConstraints = false

    return information
  }()

  func setupData(message: Message) {
    guard let messageText = message.text else { return }
    information.text = messageText
  }

  override init(frame: CGRect) {
    super.init(frame: frame.integral)
    backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    contentView.backgroundColor = backgroundColor
    information.backgroundColor = backgroundColor

    addSubview(information)
    information.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    information.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    information.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
