//
//  SelectChatTableViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import Contacts

extension NSNotification.Name {
  static let socialPointUsersUpdated = NSNotification.Name(Bundle.main.bundleIdentifier! + ".socialPointUsers")
}

class SelectChatTableViewController: UITableViewController {

  let socialPointUsersCellID = "socialPointUsersCellID"
  let newGroupCellID = "newGroupCellID"
  let newGroupAction = "New Group"
  var actions = ["New Group"]

  var users = [User]()
  var filteredUsers = [User]()
  var filteredUsersWithSection = [[User]]()

  var collation = UILocalizedIndexedCollation.current()
  var sectionTitles = [String]()
  var searchBar: UISearchBar?
  let viewPlaceholder = ViewPlaceholder()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMainView()
    setupTableView()
    setupSearchController()
    addObservers()
  }

  fileprivate func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateUsers), name: .socialPointUsersUpdated, object: nil)
  }

  @objc fileprivate func updateUsers() {

    guard let uid = CURRENT_USER?.uid else {return}
    Database.database().fetchArrayOfFollowing(userId: uid) { (users) in
        self.users = users
        print(self.users)
        self.filteredUsers = users
        print(self.filteredUsers)
        globalUsers = users
        if !globalUsers.isEmpty {
            self.viewPlaceholder.remove(from: self.view, priority: .high)
        }

        if self.searchBar != nil && !self.searchBar!.isFirstResponder {
            self.setUpCollation()
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
  }

  deinit {
    print("new chat deinit")
    NotificationCenter.default.removeObserver(self)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return ThemeManager.currentTheme().statusBarStyle
  }

  fileprivate func setupMainView() {
    navigationItem.title = "New Message"

    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
      navigationController?.navigationBar.prefersLargeTitles = true
    }

    extendedLayoutIncludesOpaqueBars = true
    definesPresentationContext = true
    edgesForExtendedLayout = [UIRectEdge.top, UIRectEdge.bottom]
    view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
  }

  @objc fileprivate func dismissNavigationController() {
    dismiss(animated: true, completion: nil)
  }

  fileprivate func setupTableView() {
    tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
    tableView.sectionIndexBackgroundColor = view.backgroundColor
    tableView.backgroundColor = view.backgroundColor
    tableView.register(SocialPointUsersTableViewCell.self, forCellReuseIdentifier: socialPointUsersCellID)
    tableView.separatorStyle = .none
  }

  fileprivate func setupSearchController() {
    searchBar = UISearchBar()
    searchBar?.delegate = self
    searchBar?.searchBarStyle = .minimal
    searchBar?.changeBackgroundColor(to: ThemeManager.currentTheme().searchBarColor)
    searchBar?.placeholder = "Search"
    searchBar?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    tableView.tableHeaderView = searchBar
  }

//  func checkContactsAuthorizationStatus() -> Bool {
//    let contactsAuthorityCheck = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
//
//    switch contactsAuthorityCheck {
//    case .denied, .notDetermined, .restricted:
//      viewPlaceholder.add(for: self.view, title: .denied, subtitle: .denied, priority: .high, position: .center)
//      return false
//    case .authorized:
//      viewPlaceholder.remove(from: self.view, priority: .high)
//      return true
//        @unknown default:
//            fatalError()
//        }
//  }

  func checkNumberOfUsers() {
    guard users.count == 0 else { return }
    viewPlaceholder.add(for: self.view, title: .empty, subtitle: .empty, priority: .low, position: .center)
  }

  fileprivate func correctSearchBarForCurrentIOSVersion() -> UISearchBar {
    var searchBar: UISearchBar!
    searchBar = self.searchBar

    return searchBar
  }

  @objc func setUpCollation() {
//    let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.filteredUsers as [AnyObject], collationStringSelector: #selector(getUserName())
//    filteredUsersWithSection = arrayContacts as! [[User]]
//    sectionTitles = arrayTitles
      setupHeaderSectionWithControls()
  }

  fileprivate func setupHeaderSectionWithControls() {
    sectionTitles.insert("", at: 0)
    filteredUsersWithSection.insert([User](), at: 0)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sectionTitles.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return actions.count
    } else {
      return filteredUsersWithSection[section].count
    }
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 65
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionTitles[section]
  }

  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return sectionTitles
  }

  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    view.tintColor = ThemeManager.currentTheme().inputTextViewColor
    if let headerTitle = view as? UITableViewHeaderFooterView {
      headerTitle.textLabel?.textColor = ThemeManager.currentTheme().generalSubtitleColor
      headerTitle.textLabel?.font = UIFont.systemFont(ofSize: 10)
    }
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 20
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return selectCell(for: indexPath)!
  }

  func selectCell(for indexPath: IndexPath) -> UITableViewCell? {

    let headerSection = 0
    if indexPath.section == headerSection {
      let cell = tableView.dequeueReusableCell(withIdentifier: newGroupCellID) ?? UITableViewCell(style: .default, reuseIdentifier: newGroupCellID)

      cell.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
      cell.imageView?.image = UIImage(named: "groupChat")
      cell.imageView?.contentMode = .scaleAspectFit
      cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
      cell.textLabel?.text = actions[indexPath.row]
      cell.textLabel?.textColor = twitterBlue
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: socialPointUsersCellID,
                                             for: indexPath) as? SocialPointUsersTableViewCell ?? SocialPointUsersTableViewCell()
    let socialPointUser = filteredUsersWithSection[indexPath.section][indexPath.row]
    cell.configureCell(for: socialPointUser)
    return cell
  }

  var chatLogController: ChatLogController?
  var messagesFetcher: MessagesFetcher?

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    if indexPath.section == 0 {
      let destination = SelectGroupMembersController()
      destination.users = users
      destination.filteredUsers = filteredUsers
     // destination.setUpCollation()
      self.navigationController?.pushViewController(destination, animated: true)
    } else {
      let socialPointUser = filteredUsersWithSection[indexPath.section][indexPath.row]

      guard let currentUserID = CURRENT_USER?.uid else { return }
      let conversationDictionary: [String: AnyObject] = ["chatID": socialPointUser.uid as AnyObject, "chatName": socialPointUser.name as AnyObject,
                                                         "isGroupChat": false  as AnyObject,
                                                         "chatOriginalPhotoURL": socialPointUser.profileImageUrl as AnyObject,
                                                         "chatThumbnailPhotoURL": socialPointUser.thumbnailPhotoURL as AnyObject,
                                                         "chatParticipantsIDs": [socialPointUser.uid, currentUserID] as AnyObject]

      let conversation = Conversation(dictionary: conversationDictionary)

      chatLogController = ChatLogController(collectionViewLayout: AutoSizingCollectionViewFlowLayout())

      messagesFetcher = MessagesFetcher()
      messagesFetcher?.delegate = self
      messagesFetcher?.loadMessagesData(for: conversation)
    }
  }
}

extension SelectChatTableViewController: MessagesDelegate {

  func messages(shouldChangeMessageStatusToReadAt reference: DatabaseReference) {
    chatLogController?.updateMessageStatus(messageRef: reference)
  }

  func messages(shouldBeUpdatedTo messages: [Message], conversation: Conversation) {

    chatLogController?.hidesBottomBarWhenPushed = true
    chatLogController?.messagesFetcher = messagesFetcher
    chatLogController?.messages = messages
    chatLogController?.conversation = conversation
    chatLogController?.observeTypingIndicator()
    chatLogController?.configureTitleViewWithOnlineStatus()
    //chatLogController?.observeMembersChanges()
    chatLogController?.messagesFetcher.collectionDelegate = chatLogController
    guard let destination = chatLogController else { return }

    if #available(iOS 11.0, *) {
    } else {
      chatLogController?.startCollectionViewAtBottom()
    }

    navigationController?.pushViewController(destination, animated: true)
    chatLogController = nil
    messagesFetcher?.delegate = nil
    messagesFetcher = nil
  }
}
