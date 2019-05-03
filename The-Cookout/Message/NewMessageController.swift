//
//  NewMessageController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: cellId)
        
        fetchFollowing()
    }
    
    func fetchFollowing() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
//        Database.database().fetchFollowing(userId: uid) { (following) in
//            self.users = [following]
//            DispatchQueue.main.async(execute: {
//                self.tableView.reloadData()
//            })
//        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserMessageCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = "@\(user.username)"
        
        let profileImageUrl = user.profileImageUrl
        cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72 
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
}
