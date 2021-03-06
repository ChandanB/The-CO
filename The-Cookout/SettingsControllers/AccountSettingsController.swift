//
//  AccountSettingsController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import ARSLineProgress

class AccountSettingsController: UITableViewController {

    let userProfileContainerView = UserProfileContainerView()
    let avatarOpener = AvatarOpener()
    let userProfileDataDatabaseUpdater = UserProfileDataDatabaseUpdater()

    let accountSettingsCellId = "userProfileCell"

    var firstSection = [( icon: UIImage(named: "Notification"), title: "Notifications and Sounds" ),
                        ( icon: UIImage(named: "Privacy"), title: "Privacy and Security" ),
                        ( icon: UIImage(named: "ChangeNumber"), title: "Change Number"),
                        ( icon: UIImage(named: "DataStorage"), title: "Data and Storage")]

    var secondSection = [( icon: UIImage(named: "Logout"), title: "Log Out")]

    let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonPressed))
    let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBarButtonPressed))
    var currentName = String()
    var currentBio = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = UIRectEdge.top
        tableView = UITableView(frame: tableView.frame, style: .grouped)

        configureTableView()
        configureContainerView()
        listenChanges()
        configureNavigationBarDefaultRightBarButton()
        addObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userProfileContainerView.username.text == "" {
            listenChanges()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tableView.tableHeaderView {

            let height = tableHeaderHeight()
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(clearUserData), name: NSNotification.Name(rawValue: "clearUserData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }

    fileprivate func configureTableView() {
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 0
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
        tableView.tableHeaderView = userProfileContainerView
        tableView.register(AccountSettingsTableViewCell.self, forCellReuseIdentifier: accountSettingsCellId)
        tableView.backgroundColor = .clear
    }

    fileprivate func configureContainerView() {
        userProfileContainerView.name.addTarget(self, action: #selector(nameDidBeginEditing), for: .editingDidBegin)
        userProfileContainerView.name.addTarget(self, action: #selector(nameEditingChanged), for: .editingChanged)
        userProfileContainerView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openUserProfilePicture)))
        userProfileContainerView.bio.delegate = self
        userProfileContainerView.name.delegate = self
    }

    func configureNavigationBarDefaultRightBarButton() {
        let nightMode = UIButton()
        nightMode.setImage(UIImage(named: "defaultTheme"), for: .normal)
        nightMode.setImage(UIImage(named: "darkTheme"), for: .selected)
        nightMode.imageView?.contentMode = .scaleAspectFit
        nightMode.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        nightMode.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        nightMode.addTarget(self, action: #selector(rightBarButtonDidTap(sender:)), for: .touchUpInside)
        nightMode.isSelected = Bool(ThemeManager.currentTheme().rawValue)

        let rightBarButton = UIBarButtonItem(customView: nightMode)
        navigationItem.setRightBarButton(rightBarButton, animated: false)
    }

    @objc fileprivate func changeTheme() {
        view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
        tableView.backgroundColor = view.backgroundColor

        navigationController?.navigationBar.barStyle = ThemeManager.currentTheme().barStyle
        navigationController?.navigationBar.barTintColor = ThemeManager.currentTheme().barBackgroundColor
        tabBarController?.tabBar.barTintColor = ThemeManager.currentTheme().barBackgroundColor
        tabBarController?.tabBar.barStyle = ThemeManager.currentTheme().barStyle
        tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle

        userProfileContainerView.backgroundColor = view.backgroundColor
        userProfileContainerView.profileImageView.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
        userProfileContainerView.userData.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
        userProfileContainerView.name.textColor = ThemeManager.currentTheme().generalTitleColor
        userProfileContainerView.bio.layer.borderColor = ThemeManager.currentTheme().inputTextViewColor.cgColor
        userProfileContainerView.bio.textColor = ThemeManager.currentTheme().generalTitleColor
        userProfileContainerView.bio.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        userProfileContainerView.name.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        tableView.reloadData()
    }

    @objc fileprivate func openUserProfilePicture() {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        avatarOpener.delegate = self
        avatarOpener.handleAvatarOpening(avatarView: userProfileContainerView.profileImageView, at: self, isEditButtonEnabled: true, title: .user)
        cancelBarButtonPressed()
    }

    @objc fileprivate func rightBarButtonDidTap(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            let theme = Theme.Dark
            ThemeManager.applyTheme(theme: theme)
        } else {
            let theme = Theme.Default
            ThemeManager.applyTheme(theme: theme)
        }
    }

    @objc func clearUserData() {
        userProfileContainerView.name.text = ""
        userProfileContainerView.username.text = ""
        userProfileContainerView.profileImageView.image = nil
    }

    func listenChanges() {

        if let currentUser = CURRENT_USER?.uid {

            let photoURLReference = USERS_REF.child(currentUser).child("profileImageUrl")
            photoURLReference.observe(.value, with: { (snapshot) in
                if let url = snapshot.value as? String {
                    self.userProfileContainerView.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: nil, options: [.scaleDownLargeImages, .continueInBackground], completed: nil)
                }
            })

            let nameReference = USERS_REF.child(currentUser).child("name")
            nameReference.observe(.value, with: { (snapshot) in
                if let name = snapshot.value as? String {
                    self.userProfileContainerView.name.text = name
                    self.currentName = name
                }
            })

            let bioReference = USERS_REF.child(currentUser).child("bio")
            bioReference.observe(.value, with: { (snapshot) in
                if let bio = snapshot.value as? String {
                    self.userProfileContainerView.bio.text = bio
                    self.userProfileContainerView.bioPlaceholderLabel.isHidden = !self.userProfileContainerView.bio.text.isEmpty
                    self.currentBio = bio
                }
            })

            let usernameReference = USERS_REF.child(currentUser).child("username")
            usernameReference.observe(.value, with: { (snapshot) in
                if let username = snapshot.value as? String {
                    self.userProfileContainerView.username.text = username
                }
            })
        }
    }

    func logoutButtonTapped () {

        guard let uid = CURRENT_USER?.uid else { return }
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: "Error signing out", message: noInternetError, controller: self)
            return
        }
        ARSLineProgress.ars_showOnView(self.tableView)

        let userReference = USERS_REF.child(uid).child("notificationTokens")
        userReference.removeValue { (error, reference) in

            Database.database().reference(withPath: ".info/connected").removeAllObservers()

            if error != nil {
                ARSLineProgress.hide()
                basicErrorAlertWith(title: "Error signing out", message: "Try again later", controller: self)
                return
            }

            let onlineStatusReference = USERS_REF.child(uid).child("OnlineStatus")
            onlineStatusReference.setValue(ServerValue.timestamp())

            Auth.auth().logout(onSuccess: {

            }) { (signOutError) in
                if let err = signOutError {
                    ARSLineProgress.hide()
                    basicErrorAlertWith(title: "Error signing out", message: err, controller: self)
                    return
                }
            }

            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            UIApplication.shared.applicationIconBadgeNumber = 0

            let destination = LoginController(alignment: .center)

            let newNavigationController = UINavigationController(rootViewController: destination)
            newNavigationController.navigationBar.shadowImage = UIImage()
            newNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)

            newNavigationController.navigationBar.isTranslucent = false
            newNavigationController.modalTransitionStyle = .crossDissolve
            ARSLineProgress.hide()
            self.present(newNavigationController, animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearUserData"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearContacts"), object: nil)
                self.tabBarController?.selectedIndex = Tabs.chats.rawValue
            })
        }
    }
}

extension AccountSettingsController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: accountSettingsCellId,
                                                 for: indexPath) as? AccountSettingsTableViewCell ?? AccountSettingsTableViewCell()
        cell.accessoryType = .disclosureIndicator

        if indexPath.section == 0 {
            cell.icon.image = firstSection[indexPath.row].icon
            cell.title.text = firstSection[indexPath.row].title
        }

        if indexPath.section == 1 {
            cell.icon.image = secondSection[indexPath.row].icon
            cell.title.text = secondSection[indexPath.row].title
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let destination = NotificationsTableViewController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            }

            if indexPath.row == 1 {
                let destination = PrivacyTableViewController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            }

            if indexPath.row == 2 {
                AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
                let controller = ChangePhoneNumberController()
                let destination = UINavigationController(rootViewController: controller)
                destination.navigationBar.shadowImage = UIImage()
                destination.navigationBar.setBackgroundImage(UIImage(), for: .default)
                destination.hidesBottomBarWhenPushed = true
                destination.navigationBar.isTranslucent = false
                present(destination, animated: true, completion: nil)
            }

            if indexPath.row == 3 {
                let destination = StorageTableViewController()
                destination.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(destination, animated: true)
            }
        }

        if indexPath.section == 1 {
            logoutButtonTapped()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return firstSection.count
        }
        if section == 1 {
            return secondSection.count
        } else {
            return 0
        }
    }
}
