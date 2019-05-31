//
//  MessagesController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

//import LBTAComponents
//import Firebase
//
//class MessagesController: UITableViewController {
//    
//    let cellId = "cellId"
//    
//    var user: User?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        fetchUserAndSetupNavBarTitle()
//        
//        tableView.register(UserMessageCell.self, forCellReuseIdentifier: cellId)
//        tableView.allowsMultipleSelectionDuringEditing = true
//    }
//    
//    func fetchUserAndSetupNavBarTitle() {
//        let image = #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal)
//        let sizedImage = image.scaleImageToSize(newSize: CGSize(width: 20, height: 20))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: sizedImage, style: .plain, target: self, action: #selector(handleNewMessage))
//        
//        navigationItem.title = "Messages"
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(dismissView))
//        
//        Database.database().fetchCurrentUser { (user) in
//            self.user = user
//            self.messages.removeAll()
//            self.messagesDictionary.removeAll()
//            self.observeUserMessages(user)
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        
//        let message = self.messages[indexPath.row]
//        
//        if let chatPartnerId = message.chatPartnerId() {
//            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
//                
//                if error != nil {
//                    print("Failed to delete message:", error!)
//                    return
//                }
//                
//                self.messagesDictionary.removeValue(forKey: chatPartnerId)
//                
//                self.attemptReloadOfTable()
//            })
//        }
//    }
//    
//    var messages = [Message]()
//    var messagesDictionary = [String: Message]()
//    
//    func observeUserMessages(_ user: User) {
//        let uid = user.uid
//        let ref = Database.database().reference().child("user-messages").child(uid)
//        
//        ref.observe(.childAdded) { (snapshot) in
//            let chatPartnerId = snapshot.key
//            ref.child(chatPartnerId).observe(.childAdded) { (snapshot) in
//                let messageId = snapshot.key
//                self.fetchMessageWithMessageId(messageId)
//            }
//        }
//        
//        ref.observe(.childRemoved) { (snapshot) in
//            print(snapshot.key)
//            print(self.messagesDictionary)
//            
//            self.messagesDictionary.removeValue(forKey: snapshot.key)
//            self.attemptReloadOfTable()
//        }
//        
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//        })
//    }
//    
//    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
//        let messagesReference = Database.database().reference().child("messages").child(messageId)
//        
//        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let message = Message(dictionary: dictionary)
//                
//                if let chatPartnerId = message.chatPartnerId() {
//                    self.messagesDictionary[chatPartnerId] = message
//                }
//                
//                self.attemptReloadOfTable()
//            }
//            
//        }, withCancel: nil)
//    }
//    
//    fileprivate func attemptReloadOfTable() {
//        self.timer?.invalidate()
//        
//        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
//    }
//    
//    var timer: Timer?
//    
//    @objc func handleReloadTable() {
//        self.messages = Array(self.messagesDictionary.values)
//        self.messages.sort(by: { (message1, message2) -> Bool in
//            
//            return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
//        })
//        
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//        })
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserMessageCell
//        
//        let message = messages[indexPath.row]
//        cell.message = message
//        
//        return cell
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 72
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let message = messages[indexPath.row]
//        
//        guard let chatPartnerId = message.chatPartnerId() else {
//            return
//        }
//        
//        let ref = Database.database().reference().child("users").child(chatPartnerId)
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                return
//            }
//            
//            let user = User(uid: chatPartnerId, dictionary: dictionary)
//            self.showChatControllerForUser(user)
//            
//        }, withCancel: nil)
//    }
//    
//    @objc func handleNewMessage() {
//        let newMessageController = NewMessageController()
//        newMessageController.messagesController = self
//        let navController = UINavigationController(rootViewController: newMessageController)
//        present(navController, animated: true, completion: nil)
//    }
//    
//    
//    
//    @objc func dismissView() {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//   
//    func showChatControllerForUser(_ user: User) {
//        let chatLogController = ChatLogController()
//        chatLogController.user = user
//        navigationController?.pushViewController(chatLogController, animated: true)
//    }
//    
//}
