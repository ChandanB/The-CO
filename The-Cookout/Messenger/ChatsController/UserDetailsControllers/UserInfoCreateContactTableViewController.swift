//
//  CreateContactTableViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import ARSLineProgress

private let createContactTableViewCellIdentifier = "CreateContactTableViewCellIdentifier"

class CreateContactTableViewController: UITableViewController {

    var user: User? {
      didSet {
        tableView.reloadData()
      }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

      navigationItem.title = "New Contact"
      tableView.separatorStyle = .none
      view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
      tableView.register(ContactDataTableViewCell.self, forCellReuseIdentifier: createContactTableViewCellIdentifier)

      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createContact))
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissController))
      if #available(iOS 11.0, *) {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
      }
    }

    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }

    @objc func createContact() {
        guard let user = self.user else {return}
        Database.database().followUser(withUID: user.uid) { (error) in
            if let err = error {
                print("Couldnt follow user with error:", err)
                return
            }
            localUserIDs.append(user.uid)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: createContactTableViewCellIdentifier, for: indexPath) as? ContactDataTableViewCell ?? ContactDataTableViewCell()

      cell.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
      cell.textField.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
      cell.textField.textColor = ThemeManager.currentTheme().generalTitleColor

      if indexPath.row == 0 {
          cell.textField.keyboardType = .default
        cell.textField.attributedPlaceholder = NSAttributedString(string: "First name", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().generalSubtitleColor])
        cell.textField.text = user?.name

      } else if indexPath.row == 1 {
          cell.textField.keyboardType = .default
        cell.textField.attributedPlaceholder = NSAttributedString(string: "Last name", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().generalSubtitleColor])

        cell.textField.text = user?.username

      } else {
        cell.textField.keyboardType = .phonePad
        cell.textField.attributedPlaceholder = NSAttributedString(string: "@", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().generalSubtitleColor])

        cell.textField.text = user?.username
      }
      return cell
    }
}
