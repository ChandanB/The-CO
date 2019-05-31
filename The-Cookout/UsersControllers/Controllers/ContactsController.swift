//
//  ContactsController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

var localUserIDs = [String]()
var globalUsers: [User] = [] {
  didSet {
    NotificationCenter.default.post(name: .socialPointUsersUpdated, object: nil)
  }
}

private let socialPointUsersCellID = "socialPointUsersCellID"
private let currentUserCellID = "currentUserCellID"
private let usersCellID = "usersCellID"

class UsersController: UITableViewController {
    
  var users = [User]()
  var filteredUsers = [User]()

  var searchBar: UISearchBar?
  var searchUsersController: UISearchController?
  
  let viewPlaceholder = ViewPlaceholder()
  let socialPointUsersFetcher = SocialPointUsersFetcher()
  let usersFetcher = UsersFetcher()

    override func viewDidLoad() {
        super.viewDidLoad()
      configureViewController()
      setupSearchController()
      addObservers()
      DispatchQueue.global(qos: .default).async { [unowned self] in
         self.usersFetcher.fetchUsers()
      }
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      guard shouldReFetchSocialPointUsers else { return }
      shouldReFetchSocialPointUsers = false
      DispatchQueue.global(qos: .default).async { [unowned self] in
        self.socialPointUsersFetcher.fetchSocialPointUsers(asynchronously: true)
      }
    }
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
      return ThemeManager.currentTheme().statusBarStyle
    }

    deinit {
      NotificationCenter.default.removeObserver(self)
    }

    fileprivate func addObservers() {
      NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: .themeUpdated, object: nil)
    }

    @objc fileprivate func changeTheme() {
      view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
      tableView.sectionIndexBackgroundColor = view.backgroundColor
      tableView.backgroundColor = view.backgroundColor
      tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
      tableView.reloadData()
    }

    fileprivate func configureViewController() {
      socialPointUsersFetcher.delegate = self
      usersFetcher.delegate = self
      extendedLayoutIncludesOpaqueBars = true
      definesPresentationContext = true
      edgesForExtendedLayout = UIRectEdge.top
      view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
      tableView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
      tableView.sectionIndexBackgroundColor = view.backgroundColor
      tableView.backgroundColor = view.backgroundColor
      tableView.register(UsersTableViewCell.self, forCellReuseIdentifier: usersCellID)
      tableView.register(SocialPointUsersTableViewCell.self, forCellReuseIdentifier: socialPointUsersCellID)
      tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: currentUserCellID)
      tableView.separatorStyle = .none
    }

    fileprivate func setupSearchController() {
      if #available(iOS 11.0, *) {
        searchUsersController = UISearchController(searchResultsController: nil)
        searchUsersController?.searchResultsUpdater = self
        searchUsersController?.obscuresBackgroundDuringPresentation = false
        searchUsersController?.searchBar.delegate = self
        navigationItem.searchController = searchUsersController
      } else {
        searchBar = UISearchBar()
        searchBar?.delegate = self
        searchBar?.placeholder = "Search"
        searchBar?.searchBarStyle = .minimal
        searchBar?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        tableView.tableHeaderView = searchBar
      }
    }
  
    fileprivate func reloadTableView(updatedUsers: [User]) {
      
      self.users = updatedUsers
      self.users = socialPointUsersFetcher.rearrangeUsers(users: self.users)
    
      let searchBar = correctSearchBarForCurrentIOSVersion()
      let isSearchInProgress = searchBar.text != ""
      let isSearchControllerEmpty = self.filteredUsers.count == 0
      
      if isSearchInProgress && !isSearchControllerEmpty {
        return
      } else {
        self.filteredUsers = self.users
        guard self.filteredUsers.count != 0 else { return }
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
  
    fileprivate func correctSearchBarForCurrentIOSVersion() -> UISearchBar {
      var searchBar: UISearchBar!
      if #available(iOS 11.0, *) {
        searchBar = self.searchUsersController?.searchBar
      } else {
        searchBar = self.searchBar
      }
      return searchBar
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
      if section == 0 {
        return 1
      } else if section == 1 {
        return filteredUsers.count
      } else {
         return filteredUsers.count
      }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if indexPath.section == 0 {
         return 85
      } else {
         return 65
      }
    }
  
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      
      if section == 0 {
        return ""
      } else if section == 1 {
      
        if filteredUsers.count == 0 {
          return ""
        } else {
          return "SocialPoint contacts"
        }
      } else {
        return "All contacts"
      }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      view.tintColor = ThemeManager.currentTheme().generalBackgroundColor
      
      if let headerTitle = view as? UITableViewHeaderFooterView {
        headerTitle.textLabel?.textColor = ThemeManager.currentTheme().generalTitleColor
      }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return selectCell(for: indexPath)
    }
  
    func selectCell(for indexPath: IndexPath) -> UITableViewCell {
      if indexPath.section == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: currentUserCellID,
                                                 for: indexPath) as? CurrentUserTableViewCell ?? CurrentUserTableViewCell()
        cell.title.text = NameConstants.personalStorage
        return cell
      } else if indexPath.section == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: socialPointUsersCellID,
                                                 for: indexPath) as? SocialPointUsersTableViewCell ?? SocialPointUsersTableViewCell()
        let user = filteredUsers[indexPath.row]
        cell.configureCell(for: user)
        return cell
        
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: usersCellID,
                                                 for: indexPath) as? UsersTableViewCell ?? UsersTableViewCell()
        cell.icon.image = UIImage(named: "UserpicIcon")
        cell.title.text = filteredUsers[indexPath.row].name + " " + filteredUsers[indexPath.row].username
        return cell
      }
    }
  
    var chatLogController: ChatLogController? = nil
    var messagesFetcher: MessagesFetcher? = nil
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      if indexPath.section == 0 {
        guard let currentUID = CURRENT_USER?.uid else { return }
        let conversationDictionary: [String: AnyObject] = ["chatID": currentUID as AnyObject,
                                                          "isGroupChat": false  as AnyObject,
                                                          "chatParticipantsIDs": [currentUID] as AnyObject]
        
        let conversation = Conversation(dictionary: conversationDictionary)
        chatLogController = ChatLogController(collectionViewLayout: AutoSizingCollectionViewFlowLayout())
        messagesFetcher = MessagesFetcher()
        messagesFetcher?.delegate = self
        messagesFetcher?.loadMessagesData(for: conversation)
      } else if indexPath.section == 1 {
        guard let currentUserID = CURRENT_USER?.uid else { return }
        let conversationDictionary: [String: AnyObject] = ["chatID": filteredUsers[indexPath.row].uid as AnyObject, "chatName": filteredUsers[indexPath.row].name as AnyObject,
                                                           "isGroupChat": false  as AnyObject,
                                                           "chatOriginalPhotoURL": filteredUsers[indexPath.row].profileImageUrl as AnyObject,
                                                           "chatThumbnailPhotoURL": filteredUsers[indexPath.row].thumbnailPhotoURL as AnyObject,
                                                           "chatParticipantsIDs": [filteredUsers[indexPath.row].uid, currentUserID] as AnyObject]
        
        let conversation = Conversation(dictionary: conversationDictionary)
        chatLogController = ChatLogController(collectionViewLayout: AutoSizingCollectionViewFlowLayout())
        messagesFetcher = MessagesFetcher()
        messagesFetcher?.delegate = self
        messagesFetcher?.loadMessagesData(for: conversation)
      } else {
        let destination = UsersDetailController()
        destination.username = filteredUsers[indexPath.row].name + " " + filteredUsers[indexPath.row].username
        destination .hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(destination, animated: true)
      }
    }
}

extension UsersController: SocialPointUsersUpdatesDelegate {
  func socialPointUsers(shouldBeUpdatedTo users: [User]) {
    globalUsers = users
    self.reloadTableView(updatedUsers: users)
  }
}

extension UsersController: MessagesDelegate {
  
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
    chatLogController?.messagesFetcher.collectionDelegate = chatLogController
    guard let destination = chatLogController else { return }
    
    if #available(iOS 11.0, *) {
    } else {
      self.chatLogController?.startCollectionViewAtBottom()
    }
    
    navigationController?.pushViewController(destination, animated: true)
    chatLogController = nil
    messagesFetcher?.delegate = nil
    messagesFetcher = nil
  }
}

extension UsersController: UsersUpdatesDelegate {
 
  func users(updateDatasource users: [User]) {
    self.users = users
    self.filteredUsers = users
    DispatchQueue.main.async { [unowned self] in
      self.tableView.reloadData()
    }
    DispatchQueue.global(qos: .default).async {
      self.socialPointUsersFetcher.fetchSocialPointUsers(asynchronously: true)
    }
  }
  
  func users(handleAccessStatus: Bool) {
    guard handleAccessStatus else {
      viewPlaceholder.add(for: view, title: .denied, subtitle: .denied, priority: .high, position: .top)
      return
    }
    viewPlaceholder.remove(from: view, priority: .high)
  }
}
