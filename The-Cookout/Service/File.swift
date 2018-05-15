//
//  AddPost.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class PostController2: UICollectionViewController, UICollectionViewDelegateFlowLayout, ReturnPostImageDelegate {
    
    var user: User? {
        didSet {
            setupProfileImage()
        }
    }
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.layer.cornerRadius = 15
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    @objc func handleOpenPhotoSelector() {
        self.handleOpenPhotoSelector2()
    }
    
    let messageTextView: UITextView = {
        let text = UITextView()
        text.text = "What's happening?"
        text.font = UIFont.boldSystemFont(ofSize: 14)
        text.isScrollEnabled = false
        text.textContainer.lineBreakMode = NSLineBreakMode.byCharWrapping
        text.sizeToFit()
        
        return text
    }()
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
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
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var selectedImage: UIImage?
    var photoSelectorController: PhotoSelectorController?
    
    func handleOpenPhotoSelector2() {
        let layout = UICollectionViewFlowLayout()
        self.photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
        self.photoSelectorController?.delegate = self
        let navController = UINavigationController(rootViewController: photoSelectorController!)
        self.present(navController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupNavigationButtons()
        
        fetchUser()
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        setupHeaderViews()
    }
    
    func setupHeaderViews() {
        collectionView?.addSubview(profileImageView)
        profileImageView.anchor(collectionView?.topAnchor, left: collectionView?.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        
        let tvHeight = messageTextView.heightAnchor.constraint(equalToConstant: 0)
        
        messageTextView.delegate = self as? UITextViewDelegate
        collectionView?.addSubview(messageTextView)
        
        let size = messageTextView.sizeThatFits(CGSize(width: messageTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != tvHeight.constant && size.height > messageTextView.frame.size.height {
            tvHeight.constant = size.height
            messageTextView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        messageTextView.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: collectionView?.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: tvHeight.constant)
        
        collectionView?.addSubview(imageView)
        imageView.anchor(messageTextView.bottomAnchor, left: messageTextView.leftAnchor, bottom: nil, right: messageTextView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 250, heightConstant: 300)
        
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.white
        
        let galleryButton = UIBarButtonItem(image: #imageLiteral(resourceName: "gallery"), style: .done, target: self, action: #selector(handleOpenPhotoSelector))
        galleryButton.tintColor = .black
        
        keyboardToolbar.items = [galleryButton]
        messageTextView.inputAccessoryView = keyboardToolbar
    }
    
    func returnPostImage(image: UIImage) {
        selectedImage = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if selectedImage != nil {
            print ("Successfully transfered image.")
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 10, right: 0)
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(sharePost))
    }
    
    @objc func sharePost() {
        print("Handling next")
    }
    
    @objc func handleCancel() {
        dismiss(animated: false, completion: nil)
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            self.user = User(dictionary: dictionary as [String : AnyObject])
            
            self.collectionView?.reloadData()
        }
    }
}
