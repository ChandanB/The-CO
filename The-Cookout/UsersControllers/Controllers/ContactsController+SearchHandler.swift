//
//  ContactsController+SearchHandler.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/4/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

extension UsersController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {}

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filteredUsers = users
        tableView.reloadData()
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
            return
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
        guard #available(iOS 11.0, *) else {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = searchText.isEmpty ? users : users.filter({ (User) -> Bool in
            return User.name.lowercased().contains(searchText.lowercased())
        })

        filteredUsers = searchText.isEmpty ? users : users.filter({ (User) -> Bool in
            let userFullName = User.name.lowercased() + " " + User.username.lowercased()
            return userFullName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension UsersController { /* hiding keyboard */

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            searchUsersController?.resignFirstResponder()
            searchUsersController?.searchBar.resignFirstResponder()
        } else {
            searchBar?.resignFirstResponder()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if #available(iOS 11.0, *) {
            searchUsersController?.searchBar.endEditing(true)
        } else {
            self.searchBar?.endEditing(true)
        }
    }
}

