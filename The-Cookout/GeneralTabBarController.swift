//
//  GeneralTabBarController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase


enum Tabs: Int {
  case chats = 0
  case contacts = 1
  case settings = 2
}

class GeneralTabBarController: UITabBarController {
  
  var onceToken = 0
  
  let splashContainer: SplashScreenContainer = {
    let splashContainer = SplashScreenContainer()
    splashContainer.translatesAutoresizingMaskIntoConstraints = false
    
    return splashContainer
  }()
  
  override func viewDidLoad() {
      super.viewDidLoad()
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
    navigationItem.leftBarButtonItem?.tintColor = .black
    
    let optionsButton = UIBarButtonItem(title: "•••", style: .plain, target: self, action: #selector(handleSettings))
    optionsButton.tintColor = .black
    navigationItem.rightBarButtonItem = optionsButton
    
    chatsController.delegate = self
    setOnlineStatus()
    configureTabBar()
  }
    @objc private func handleBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSettings() {
        settingsController.title = "Settings"
        present(settingsController, animated: true, completion: nil)
//        navigationController?.pushViewController(settingsController, animated: true)
    }
  
  fileprivate func configureTabBar() {
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().generalSubtitleColor], for: .normal)
    tabBar.unselectedItemTintColor = ThemeManager.currentTheme().generalSubtitleColor
    tabBar.isTranslucent = false
    tabBar.layer.borderWidth = 0.50
    tabBar.layer.borderColor = UIColor.clear.cgColor
    tabBar.clipsToBounds = true
    setTabs()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
 
    if onceToken == 0 {
      view.addSubview(splashContainer)
      splashContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
      splashContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
      splashContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      splashContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    onceToken = 1
  }
  
  let usersController = UsersController()
  let chatsController = ChatsTableViewController()
  let settingsController = AccountSettingsController()
  
  fileprivate func setTabs() {
    
    usersController.title = "Contacts"
    chatsController.title = "Chats"
    
    let usersNavigationController = UINavigationController(rootViewController: usersController)
    let chatsNavigationController = UINavigationController(rootViewController: chatsController)
    let settingsNavigationController = UINavigationController(rootViewController: settingsController)
    
    if #available(iOS 11.0, *) {
      settingsNavigationController.navigationBar.prefersLargeTitles = true
      chatsNavigationController.navigationBar.prefersLargeTitles = true
      usersNavigationController.navigationBar.prefersLargeTitles = true
    }
    
    let contactsImage =  UIImage(named: "user")
    let chatsImage = UIImage(named: "chat")
    let settingsImage = UIImage(named: "settings")
    
    let contactsTabItem = UITabBarItem(title: usersController.title, image: contactsImage, selectedImage: nil)
    let chatsTabItem = UITabBarItem(title: chatsController.title, image: chatsImage, selectedImage: nil)
    let settingsTabItem = UITabBarItem(title: settingsController.title, image: settingsImage, selectedImage: nil)
    
    usersController.tabBarItem = contactsTabItem
    chatsController.tabBarItem = chatsTabItem
    settingsController.tabBarItem = settingsTabItem
    
    let tabBarControllers = [chatsNavigationController as UIViewController, usersNavigationController as UIViewController, settingsNavigationController as UIViewController]
    
    viewControllers = tabBarControllers
    selectedIndex = Tabs.chats.rawValue
  }
  
  func presentOnboardingController() {
    guard CURRENT_USER == nil else { return }
    let destination = LoginController()
    let newNavigationController = UINavigationController(rootViewController: destination)
    newNavigationController.navigationBar.shadowImage = UIImage()
    newNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
    newNavigationController.modalTransitionStyle = .crossDissolve
    present(newNavigationController, animated: false, completion: nil)
  }
}

extension GeneralTabBarController: ManageAppearance {
  func manageAppearance(_ chatsController: ChatsTableViewController, didFinishLoadingWith state: Bool) {
    let isBiometricalAuthEnabled = userDefaults.currentBoolObjectState(for: userDefaults.biometricalAuth)
    _ = usersController.view
    _ = settingsController.view
    guard state else { return }
    if isBiometricalAuthEnabled {
      splashContainer.authenticationWithTouchID()
    } else {
      self.splashContainer.showSecuredData()
    }
  }
}
