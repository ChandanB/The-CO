//
//  UserSeachController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/16/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase

class UserSearchController: DatasourceController, UISearchBarDelegate {

    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.autocorrectionType = .no
        sb.autocapitalizationType = .none
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(r: 230, g: 230, b: 230)
        sb.autocapitalizationType = .none
        return sb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black

        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag

        self.datasource = self.searchDatasource
        self.searchBar.delegate = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl

        fetchUsers()
        fetchTopUsers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }

    fileprivate func fetchUsers() {
        Database.database().fetchAllUsers(includeCurrentUser: false, completion: { (users) in
            self.searchDatasource.users = users
            self.searchDatasource.filteredUsers = users
            self.searchBar.text = ""
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (err) in
            print(err.localizedDescription)
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }

    @objc override func handleRefresh() {
        fetchUsers()
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()

        let layout = StretchyHeaderLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let user = self.searchDatasource.filteredUsers[indexPath.item]
        userProfileController.user = user

        navigationController?.pushViewController(userProfileController, animated: true)
    }

    let searchDatasource = SearchDataSource()
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    fileprivate func fetchTopUsers() {
        let ref = Database.database().reference().child("topUsers")

        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: AnyObject]
                else { return }

            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: AnyObject] else { return }
                let user = User(uid: key, dictionary: dictionary)
                self.searchDatasource.topUsers.append(user)
            })

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if section == 1 {
            return .zero
        }

        if searchDatasource.topUsers.count == 0 {
            return .zero
        }

        return CGSize(width: view.frame.width, height: 33)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        if section == 1 {
            return .zero
        }

        if searchDatasource.topUsers.count == 0 {
            return .zero
        }

        return CGSize(width: view.frame.width, height: 40)
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.section == 0 {
            if let user = self.datasource?.item(indexPath) as? User {
                let estimatedHeight = estimatedHeightForText(user.bio)
                return CGSize(width: view.frame.width, height: estimatedHeight + 66)
            }
        }

        return CGSize(width: view.frame.width, height: 66)
    }

    private func estimatedHeightForText(_ text: String) -> CGFloat {
        let approximateWidthOfTextView = view.frame.width - 12 - 50 - 12 - 2
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]

        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return estimatedFrame.height
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }

}

// MARK: - UISearchBarDelegate
extension UserSearchController {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            self.searchDatasource.filteredUsers = self.searchDatasource.users
        } else {
            self.searchDatasource.filteredUsers = self.searchDatasource.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }

        self.collectionView?.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
