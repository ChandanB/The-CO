//
//  PostHeader.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents

protocol ReturnPostTextDelegate {
    func returnPostText(text: UITextView)
}

class PostHeader: UICollectionViewCell, UITextViewDelegate {
    
    var user: User? {
        didSet {
            setupProfileImage()
        }
    }
    
    var textdelegate : ReturnPostTextDelegate?
    var imageDelegate : ReturnPostImageDelegate?
    
//    lazy var containerView: UIView = {
//
//        var showCameraButton: SpringButton = {
//            let button = SpringButton()
//            button.setImage(#imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), for: .normal)
//            button.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
//            button.layer.cornerRadius = 5
//            button.layer.borderWidth = 1
//            button.clipsToBounds = true
//            button.backgroundColor = .white
//            return button
//        }()
//
//
//        let containerView = UIView()
//        containerView.backgroundColor = .white
//        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
//
//        var galleryButton = UIButton(type: .system)
//        galleryButton.setImage(#imageLiteral(resourceName: "gallery").withRenderingMode(.alwaysOriginal), for: .normal)
//        galleryButton.tintColor = .black
//        galleryButton.addTarget(self, action: #selector(handleOpenPhotoSelector), for: .touchUpInside)
//
//        containerView.addSubview(galleryButton)
//        galleryButton.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 0)
//
//        containerView.addSubview(showCameraButton)
//        showCameraButton.anchor(nil, left: containerView.leftAnchor, bottom: containerView.topAnchor, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 12, rightConstant: 0, widthConstant: 60, heightConstant: 60)
//        showCameraButton.layer.zPosition = -1
//
//        return containerView
//    }()
//
//    @objc func handleSubmit() {
//        print("Handling Submit...")
//    }
//
//    @objc func handleOpenPhotoSelector() {
//        print("OOPNE")
//        self.postController?.handleOpenPhotoSelector()
//    }
//
//    override var inputAccessoryView: UIView? {
//        get {
//            return containerView
//        }
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    var postController: PostController?
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.layer.cornerRadius = 15
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    @objc func handleOpenPhotoSelector() {
        self.postController?.handleOpenPhotoSelector()
    }
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.text = "What's on your mind?"
        textView.textColor = UIColor.lightGray
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = NSLineBreakMode.byCharWrapping
        textView.sizeToFit()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        return textView
    }()
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            textView.text = "What's on your mind?"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            if imageView.image == nil {
                self.postController?.shareButton.isEnabled = false
                self.postController?.shareButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
            }
            
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            
            textView.textColor = UIColor.black
            textView.text = text
            
            self.postController?.shareButton.isEnabled = true
            self.postController?.shareButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
            
        } else {
            
            return true
        }
        
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if imageView.image != nil {
            textView.text = "Say something about this picture?"
            self.postController?.shareButton.isEnabled = true
            self.postController?.shareButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
        } else {
            self.postController?.shareButton.isEnabled = false
            self.postController?.shareButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty && imageView.image == nil {
            textView.text = "What's on your mind?"
            textView.textColor = UIColor.lightGray
        } else if imageView.image != nil && textView.text.isEmpty {
            textView.text = "Say something about this picture?"
            self.postController?.shareButton.isEnabled = true
            self.postController?.shareButton.backgroundColor = UIColor(r: 17, g: 154, b: 237)
            self.imageDelegate?.returnPostImage(image: imageView.image!)
        }
        
        self.textdelegate?.returnPostText(text: textView)
    }
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        
        let tvHeight = messageTextView.heightAnchor.constraint(equalToConstant: 0)
        
        messageTextView.delegate = self
        addSubview(messageTextView)
        
        let size = messageTextView.sizeThatFits(CGSize(width: messageTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != tvHeight.constant && size.height > messageTextView.frame.size.height {
            tvHeight.constant = size.height
            messageTextView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        messageTextView.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: tvHeight.constant)
        
        addSubview(imageView)
        imageView.anchor(messageTextView.bottomAnchor, left: messageTextView.leftAnchor, bottom: nil, right: messageTextView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 250, heightConstant: 400)
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.white
        
        let galleryButton = UIBarButtonItem(image: #imageLiteral(resourceName: "gallery").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(handleOpenPhotoSelector))
        galleryButton.tintColor = .black
        
        let showCameraButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Camera3").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(showCamera))
        
        keyboardToolbar.items = [galleryButton, showCameraButton]
        messageTextView.inputAccessoryView = keyboardToolbar
    }
    
    @objc func showCamera(){
        self.postController?.handleShowCamera()
    }
    
    func showKeyboard() {
        messageTextView.becomeFirstResponder()
    }
    
    fileprivate func setupProfileImage() {
        guard let url = user?.profileImageUrl else { return }
        self.profileImageView.loadImage(urlString: url)
        
        DispatchQueue.main.async {
            self.profileImageView.loadImage(urlString: url)
            self.showKeyboard()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
