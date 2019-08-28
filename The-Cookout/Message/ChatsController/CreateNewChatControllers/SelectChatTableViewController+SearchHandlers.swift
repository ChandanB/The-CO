//
//  SelectChatTableViewController+SearchHandlers.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

extension SelectChatTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {}

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    filteredUsers = users
    guard users.count > 0 else { return }
    actions.append(newGroupAction)
    setUpCollation()
    self.tableView.reloadData()
    searchBar.setShowsCancelButton(false, animated: true)
    searchBar.resignFirstResponder()
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    actions.removeAll()
    tableView.reloadData()
  }

  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    searchBar.setShowsCancelButton(true, animated: true)

    return true
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    if searchText.isEmpty {
        self.filteredUsers = self.users
    } else {
        self.filteredUsers = self.users.filter { (user) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        }
    }

    setUpCollation()
    self.tableView.reloadData()
  }
}

extension SelectChatTableViewController { /* hiding keyboard */

  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar?.resignFirstResponder()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.searchBar?.resignFirstResponder()
    self.searchBar?.endEditing(true)
  }
}
