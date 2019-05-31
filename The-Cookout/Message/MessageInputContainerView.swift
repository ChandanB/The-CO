//
//  MessageInputContainerView.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

//class ChatInputContainerView: UIView, UITextFieldDelegate {
//    
//    weak var chatLogController: ChatLogController? {
//        didSet {
//            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
//            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
//        }
//    }
//    
//    lazy var inputTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter message..."
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.delegate = self
//        return textField
//    }()
//    
//    let uploadImageView: UIImageView = {
//        let uploadImageView = UIImageView()
//        uploadImageView.isUserInteractionEnabled = true
//        uploadImageView.image = #imageLiteral(resourceName: "gallery")
//        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
//        return uploadImageView
//    }()
//    
//    let separatorLineView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    let sendButton = UIButton(type: .system)
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        backgroundColor = .white
//        
//        addSubview(uploadImageView)
//        addSubview(sendButton)
//        addSubview(inputTextField)
//        addSubview(separatorLineView)
//
//
//        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
//        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        
//        sendButton.setTitle("Send", for: UIControl.State())
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
//        
//        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
//        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
//        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
//        
//        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        chatLogController?.handleSend()
//        return true
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
