//
//  SelectNewAdminTableViewController+SearchHandlers.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

extension SelectNewAdminTableViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

  func updateSearchResults(for searchController: UISearchController) {}

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    filteredUsers = users
    guard users.count > 0 else { return }
    searchBar.setShowsCancelButton(false, animated: true)
    searchBar.resignFirstResponder()
    tableView.reloadData()
  }

  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    searchBar.setShowsCancelButton(true, animated: true)

    return true
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filteredUsers = searchText.isEmpty ? users : users.filter({ (User) -> Bool in
        return User.name.lowercased().contains(searchText.lowercased())
    })

    tableView.reloadData()
  }
}

extension SelectNewAdminTableViewController { /* hiding keyboard */

  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar?.resignFirstResponder()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.searchBar?.endEditing(true)
  }
}