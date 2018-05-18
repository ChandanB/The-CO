//
//  AddPost.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Firebase

class PostController: DatasourceController, ReturnPostImageDelegate, ReturnPostTextDelegate {
    
    let cellId = "cellId"
    let headerId = "headerId"
    var user: User?
    
    var selectedImage: UIImage?
    var messageTextView: UITextView?
    var photoSelectorController: PhotoSelectorController?
    var postHeader: PostHeader?
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(sharePost), for: .touchUpInside)
        return button
    }()
    
    func handleOpenPhotoSelector() {
        let layout = UICollectionViewFlowLayout()
        self.photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
        self.photoSelectorController?.delegate = self
        let navController = UINavigationController(rootViewController: photoSelectorController!)
        self.present(navController, animated: true, completion: nil)
    }
    
    func handleShowCamera() {
        let cameraController = CameraController()
        self.present(cameraController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTapped()

        self.postHeader?.textdelegate = self
        self.postHeader?.imageDelegate = self
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupNavigationButtons()
        
        fetchUser()
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(PostHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    func returnPostImage(image: UIImage) {
        selectedImage = image
    }
    
    func returnPostText(text: UITextView) {
        messageTextView = text
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
        return UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        let height = view.frame.height
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PostHeader
        
        self.postHeader = header
        header.backgroundColor = .white
        header.postController = self
        header.user = self.user
        header.imageView.image = selectedImage
        self.messageTextView = self.postHeader?.messageTextView
        
        return header
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        let menuBarItem = UIBarButtonItem(customView: shareButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 60)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
        
    }
    
    @objc func sharePost() {
        print("Share clicked")
        dismissKeyboard()
        if selectedImage != nil {
            shareImagePost()
        } else {
            guard let user = self.user else { return }
            shareTextPost(user)
        }
    }
    
    func shareImagePost() {
        guard let image = self.selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.4) else { return }
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("posts").child("\(filename).jpg")
        
        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            
            if let err = error {
                print("Failed to upload post image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                
                if let err = error {
                    print("Failed to get post url:", err)
                    return
                }
                
                guard let imageUrl = url else { return }
                guard let user = self.user else { return }
                
                let postImageUrl = imageUrl.absoluteString
                
                print("Successfully uploaded post image:", postImageUrl)
                
                self.saveToDatabaseWithImageUrl(postImageUrl, user: user)
            })
        })
    }
    
    fileprivate func saveToDatabaseWithImageUrl(_ imageUrl: String, user: User) {
        guard let postImage = selectedImage else { return }
        guard let caption = messageTextView?.text else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        var trimmedCaption = caption.trim()
        
        if trimmedCaption == "What's on your mind?" || trimmedCaption == "Say something about this picture?" {
            trimmedCaption = ""
        }
        
        let values =
            ["imageUrl": imageUrl,
             "caption": trimmedCaption,
             "imageWidth": postImage.size.width,
             "imageHeight": postImage.size.height,
             "creationDate": Date().timeIntervalSince1970,
             "profileImageUrl": user.profileImageUrl,
             "name": user.name,
             "username": user.username] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("Failed to save post to DB", err)
                return
            }
            
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: PostController.updateFeedNotificationName, object: nil)
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "updateFeed")

    func shareTextPost(_ user: User) {
        guard let caption = messageTextView?.text else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        let trimmedCaption = caption.trim()
        
        if trimmedCaption == ""  {
            return
        }
        
        let values = ["caption": caption.trim(),
                      "creationDate": Date().timeIntervalSince1970,
                      "profileImageUrl": user.profileImageUrl,
                      "name": user.name,
                      "username": user.username] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print("Failed to save post to DB", err)
                return
            }
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: PostController.updateFeedNotificationName, object: nil)
        }
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: false, completion: nil)
    }
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            self.user = User(uid: uid, dictionary: dictionary as [String : AnyObject])
            
            self.collectionView?.reloadData()
        }
    }
    
    private var lastContentOffset: CGFloat = 0
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 {
            UIView.animate(withDuration: 0.7, animations: {
                scrollView.setContentOffset(.zero, animated: false)
            })
        }
    }
    
}


