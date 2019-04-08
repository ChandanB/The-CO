////
////  ChatLogController.swift
////  The-Cookout
////
////  Created by Chandan Brown on 5/20/18.
////  Copyright © 2018 Chandan B. All rights reserved.
////
//
//import LBTAComponents
//import Firebase
//import MobileCoreServices
//import AVFoundation
//
//
//class ChatLogController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    var user: User? {
//        didSet {
//            navigationItem.title = user?.name
//            observeMessages()
//        }
//    }
//
//    var messages = [Message]()
//
//    var startingFrame: CGRect?
//    var blackBackgroundView: UIView?
//    var startingImageView: UIImageView?
//
//    let cellId = "cellId"
//
//    var chatMessages = [[Message]]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupKeyboardObservers()
//
//        // navigationItem.title = "Messages"
//        // navigationController?.navigationBar.prefersLargeTitles = true
//
//        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
//    }
//
//
//    func observeMessages() {
//        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.uid else {
//            return
//        }
//
//        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
//        userMessagesRef.observe(.childAdded, with: { (snapshot) in
//
//            let messageId = snapshot.key
//            let messagesRef = Database.database().reference().child("messages").child(messageId)
//            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//
//                guard let dictionary = snapshot.value as? [String: AnyObject] else {
//                    return
//                }
//                let message = Message(dictionary: dictionary)
//                self.messages.append(message)
//                self.attemptToAssembleGroupedMessages()
//
//                DispatchQueue.main.async(execute: {
//                    self.tableView?.reloadData()
//                })
//
//            }, withCancel: nil)
//
//        }, withCancel: nil)
//    }
//
//    lazy var inputContainerView: ChatInputContainerView = {
//        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
//        chatInputContainerView.chatLogController = self
//        return chatInputContainerView
//    }()
//
//    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
//        if let profileImageUrl = self.user?.profileImageUrl {
//            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
//
//        if message.fromId == Auth.auth().currentUser?.uid {
//            //outgoing blue
//            cell.bubbleBackgroundView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
//            cell.profileImageView.isHidden = true
//            cell.messageLabel.textColor = .black
//            cell.bubbleViewRightAnchor?.isActive = true
//            cell.bubbleViewLeftAnchor?.isActive = false
//
//        } else {
//            //incoming gray
//            cell.bubbleBackgroundView.backgroundColor = .clear
//            cell.bubbleBackgroundView.layer.borderWidth = 0.2
//            cell.bubbleBackgroundView.layer.borderColor = UIColor.gray.cgColor
//            cell.messageLabel.textColor = .black
//            cell.profileImageView.isHidden = false
//
//            cell.bubbleViewRightAnchor?.isActive = false
//            cell.bubbleViewLeftAnchor?.isActive = true
//        }
//
//        if let messageImageUrl = message.imageUrl {
//            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
//            cell.messageImageView.isHidden = false
//            cell.bubbleBackgroundView.backgroundColor = UIColor.clear
//        } else {
//            cell.messageImageView.isHidden = true
//        }
//    }
//
//    @objc func handleSend() {
//        let properties = ["text": inputContainerView.inputTextField.text!]
//        sendMessageWithProperties(properties as [String : AnyObject])
//    }
//
//    func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
//        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
//        sendMessageWithProperties(properties)
//    }
//
//    func sendMessageWithProperties(_ properties: [String: AnyObject]) {
//        let ref = Database.database().reference().child("messages")
//        let childRef = ref.childByAutoId()
//        guard let toId = user?.uid else {return}
//        guard let fromId = Auth.auth().currentUser?.uid else {return}
//        let timestamp = Int(Date().timeIntervalSince1970)
//
//        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
//
//        properties.forEach({values[$0] = $1})
//
//        childRef.updateChildValues(values) { (error, ref) in
//            if error != nil {
//                print(error!)
//                return
//            }
//
//            self.inputContainerView.inputTextField.text = nil
//
//            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
//
//            let messageId = childRef.key
//            userMessagesRef.updateChildValues([messageId: 1])
//
//            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
//            recipientUserMessagesRef.updateChildValues([messageId: 1])
//        }
//    }
//
//    fileprivate func attemptToAssembleGroupedMessages() {
//        print("Attempt to group our messages together based on Timestamp property")
//
//        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
//            let date = Date(timeIntervalSince1970: element.timestamp as! TimeInterval)
//            print(date)
//            return date.reduceToMonthDayYear()
//        }
//
//        // provide a sorting for your keys somehow
//        let sortedKeys = groupedMessages.keys.sorted()
//        sortedKeys.forEach { (key) in
//            let values = groupedMessages[key]
//            chatMessages.append(values ?? [])
//        }
//
//        print(groupedMessages)
//
//    }
//
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return chatMessages.count
//    }
//
//    class DateHeaderLabel: UILabel {
//
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//
//            backgroundColor = .black
//            textColor = .white
//            textAlignment = .center
//            translatesAutoresizingMaskIntoConstraints = false
//            font = UIFont.boldSystemFont(ofSize: 14)
//        }
//
//        required init?(coder aDecoder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//
//        override var intrinsicContentSize: CGSize {
//            let originalContentSize = super.intrinsicContentSize
//            let height = originalContentSize.height + 12
//            layer.cornerRadius = height / 2
//            layer.masksToBounds = true
//            return CGSize(width: originalContentSize.width + 20, height: height)
//        }
//
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if let firstMessageInSection = chatMessages[section].first {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/yyyy"
//            let date = Date(timeIntervalSince1970: firstMessageInSection.timestamp as! TimeInterval)
//            let dateString = dateFormatter.string(from: date)
//
//            let label = DateHeaderLabel()
//            label.text = dateString
//
//            let containerView = UIView()
//
//            containerView.addSubview(label)
//            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
//            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//
//            return containerView
//
//        }
//        return nil
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return chatMessages[section].count
//    }
//
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
//        let chatMessage = chatMessages[indexPath.section][indexPath.row]
//        cell.chatMessage = chatMessage
//        cell.messageLabel.text = chatMessage.text
//        setupCell(cell, message: chatMessage)
//
//        if let text = chatMessage.text {
//            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
//            cell.messageLabel.isHidden = false
//        } else if chatMessage.imageUrl != "" {
//            cell.bubbleWidthAnchor?.constant = 200
//            cell.messageLabel.isHidden = true
//        }
//
//        cell.playButton.isHidden = chatMessage.videoUrl == ""
//
//        return cell
//    }
//
//    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
//        let size = CGSize(width: 200, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
//    }
//}
//
//
