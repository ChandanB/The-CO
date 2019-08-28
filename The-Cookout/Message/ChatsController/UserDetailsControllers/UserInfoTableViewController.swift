//
//  UserInfoTableViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase

private let headerCellIdentifier = "headerCellIdentifier"
private let phoneNumberCellIdentifier = "phoneNumberCellIdentifier"
private let bioCellIdentifier = "bioCellIdentifier"

class UserInfoTableViewController: UITableViewController {

  var user: User? {
    didSet {
      uid = user?.uid ?? ""
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }

  var conversationID = String()
  var onlineStatus = String()
  var uid = String()

  var userReference: DatabaseReference!
  var handle: DatabaseHandle!
  var shouldDisplayContactAdder: Bool?

  override func viewDidLoad() {
    super.viewDidLoad()

    setupMainView()
    setupTableView()
    getUserInfo()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    if userReference != nil {
      userReference.removeObserver(withHandle: handle)
    }
  }

  fileprivate func setupMainView() {
    title = "Info"
    extendedLayoutIncludesOpaqueBars = true
    view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
    }
  }

  fileprivate func setupTableView() {
    tableView.separatorStyle = .none
    tableView.register(UserinfoHeaderTableViewCell.self, forCellReuseIdentifier: headerCellIdentifier)
    tableView.register(UserInfoUsernameTableViewCell.self, forCellReuseIdentifier: phoneNumberCellIdentifier)
  }

  fileprivate func getUserInfo() {
    userReference = USER_REF.child(conversationID)
    handle = userReference.observe(.value) { (snapshot) in
      if snapshot.exists() {
        guard var dictionary = snapshot.value as? [String: AnyObject] else { return }
        dictionary.updateValue(snapshot.key as AnyObject, forKey: "uid")
        self.user = User(uid: snapshot.key, dictionary: dictionary)
      }
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

    if indexPath.section == 0 {
      return 100
    } else {
      return 200
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let usernameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? UserInfoUsernameTableViewCell ?? UserInfoUsernameTableViewCell()

    if localUserIDs.contains(uid.digits) {
      usernameCell.add.isHidden = true
      usernameCell.contactStatus.isHidden = true
      usernameCell.addHeightConstraint.constant = 0
      usernameCell.contactStatusHeightConstraint.constant = 0
    } else {
      usernameCell.add.isHidden = false
      usernameCell.contactStatus.isHidden = false
      usernameCell.addHeightConstraint.constant = 40
      usernameCell.contactStatusHeightConstraint.constant = 40
    }
  }

  fileprivate func stringTimestamp(onlineStatusObject: AnyObject) -> String {
    if let onlineStatusStringStamp = onlineStatusObject as? String, onlineStatusStringStamp == statusOnline {
      return statusOnline
    } else if let onlineStatusTimeIntervalStamp = onlineStatusObject as? TimeInterval { //user got server timestamp in miliseconds
      let date = Date(timeIntervalSince1970: onlineStatusTimeIntervalStamp/1000)
      let subtitle = "Last seen " + timeAgoSinceDate(date)
      return subtitle
    }
    return ""
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if indexPath.section == 0 {

      let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier,
                                                     for: indexPath) as? UserinfoHeaderTableViewCell ?? UserinfoHeaderTableViewCell()

      headerCell.title.text = user?.name ?? ""
      headerCell.title.font = UIFont.boldSystemFont(ofSize: 20)

      if let timestamp = user?.onlineStatus {
        headerCell.subtitle.text = stringTimestamp(onlineStatusObject: timestamp)
      }

      headerCell.selectionStyle = .none

      guard let photoURL = user?.profileImageUrl else { headerCell.icon.image = UIImage(named: "UserpicIcon"); return headerCell }
      headerCell.icon.showActivityIndicator()
      headerCell.icon.sd_setImage(with: URL(string: photoURL), placeholderImage: UIImage(named: "UserpicIcon"), options: [.continueInBackground, .scaleDownLargeImages], completed: { (_, error, _, _) in
         headerCell.icon.hideActivityIndicator()
        guard error == nil else { return }
        headerCell.icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openPhoto)))
      })

      return headerCell
    } else {
      let usernameCell = tableView.dequeueReusableCell(withIdentifier: phoneNumberCellIdentifier,
                                                          for: indexPath) as? UserInfoUsernameTableViewCell ?? UserInfoUsernameTableViewCell()
      usernameCell.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor

      if localUserIDs.contains(uid.digits) {
        usernameCell.add.isHidden = true
        usernameCell.contactStatus.isHidden = true
        usernameCell.addHeightConstraint.constant = 0
        usernameCell.contactStatusHeightConstraint.constant = 0
      } else {
        usernameCell.add.isHidden = false
        usernameCell.contactStatus.isHidden = false
        usernameCell.addHeightConstraint.constant = 40
        usernameCell.contactStatusHeightConstraint.constant = 40
      }

      usernameCell.phoneLabel.textColor = ThemeManager.currentTheme().generalTitleColor
      usernameCell.userInfoTableViewController = self
      usernameCell.phoneLabel.text = user?.phoneNumber ?? ""
      usernameCell.phoneLabel.font = UIFont.systemFont(ofSize: 17)
      usernameCell.bio.text = user?.bio ?? ""
      usernameCell.bio.textColor = ThemeManager.currentTheme().generalTitleColor

      return usernameCell

    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       self.tableView.deselectRow(at: indexPath, animated: true)
  }
}
