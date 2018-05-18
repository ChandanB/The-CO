//
//  UserSeachController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/16/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase
import BoltsSwift


class UserSearchController : DatasourceController, UISearchBarDelegate {
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(r: 230, g: 230, b: 230)
        sb.autocapitalizationType = .none
        return sb
    }()
    
    let placeholderWidth: CGFloat = 200.0
    var offset = UIOffset()

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.searchDatasource.filteredUsers = self.searchDatasource.users
        } else {
            self.searchDatasource.filteredUsers = self.searchDatasource.users.filter { (user) -> Bool in
                return user.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = self.searchDatasource.filteredUsers[indexPath.item]
        
        let userProfileController = UserProfileController()
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    let searchDatasource = SearchDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let navBar = navigationController?.navigationBar else { return }
        
        navBar.addSubview(searchBar)
        searchBar.anchor(navBar.topAnchor, left: navBar.leftAnchor, bottom: navBar.bottomAnchor, right: navBar.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        
        offset = UIOffset(horizontal: (searchBar.frame.width + placeholderWidth) / 2, vertical: 0)
        searchBar.setPositionAdjustment(offset, for: .search)
        
        self.datasource = self.searchDatasource
        self.searchBar.delegate = self
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        fetchUsers()
        fetchTopUsers()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let noOffset = UIOffset(horizontal: 0, vertical: 0)
        searchBar.setPositionAdjustment(noOffset, for: .search)
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setPositionAdjustment(offset, for: .search)
        
        return true
    }
    
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: AnyObject]
                else { return }
            
            dictionaries.forEach({ (key, value) in
                
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself, omit from list")
                    return
                }
                
                guard let dictionary = value as? [String: AnyObject] else { return }
                let user = User(uid: key, dictionary: dictionary)
                self.searchDatasource.users.append(user)
            })
            
            self.searchDatasource.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            self.searchDatasource.filteredUsers = self.searchDatasource.users
            self.collectionView?.reloadData()
        }
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
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = UIColor.white
    }
    
}
