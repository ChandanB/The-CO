//
//  AddPost.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import PKHUD
import AVKit
import YPImagePicker

class PostController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ReturnPostImageDelegate, ReturnPostTextDelegate, UITextViewDelegate {
    
    let cellId = "cellId"
    let headerId = "headerId"
    var user: User?
    
    var uploadAction: UploadAction!
    var postToEdit: Post?
    
    enum UploadAction: Int {
        case UploadPost
        case SaveChanges
        
        init(index: Int) {
            switch index {
            case 0: self = .UploadPost
            case 1: self = .SaveChanges
            default: self = .UploadPost
            }
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            postHeader?.imageView.image = selectedImage
        }
    }
    
    private var captionTextView: PlaceholderTextView = {
        let tv = PlaceholderTextView()
        tv.placeholderLabel.text = "Add a caption..."
        tv.placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.autocorrectionType = .no
        return tv
    }()
    
    var photoSelectorController: PhotoSelectorController?
    var postHeader: PostHeader?
    var config = YPImagePickerConfiguration()
    
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
    
    func handleOpenGallery() {
        
        config.library.mediaType = .photoAndVideo
        config.targetImageSize = .original
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .cappedTo(size: 1080)
        config.shouldSaveNewPicturesToAlbum = true
        config.video.compression = AVAssetExportPresetHighestQuality
        config.albumName = "Social Point"
        config.screens = [.library]
        config.video.libraryTimeLimit = 600
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = true
        
        YPImagePickerConfiguration.shared = config
        let picker = YPImagePicker()
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage ?? "") // Transformed image, can be nil
                self.selectedImage = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        
        captionTextView.delegate = self
    }
    
    func configureViewComponents() {
        self.hideKeyboardWhenTappedAround()
        
        self.postHeader?.textdelegate = self
        self.postHeader?.imageDelegate = self
        
        collectionView?.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupNavigationButtons()
        
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PostHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    func returnPostImage(image: UIImage) {
        selectedImage = image
    }
    
    func returnPostText(text: PlaceholderTextView) {
        captionTextView = text
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
        self.captionTextView = self.postHeader!.captionTextView
        
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
        guard let user = self.user else { return }
        dismissKeyboard()
        
        if selectedImage == nil {
            shareTextPost(user)
            return
        }
        
        shareImagePost(user)
    }
    
    func shareImagePost(_ user: User) {
        
        guard
            let caption = captionTextView.text,
            let image = selectedImage else { return }
        
        let trimmedCaption = caption.trim()
        
        if trimmedCaption == ""  {
            return
        }
       
        Database.database().createImagePost(withImage: image, caption: trimmedCaption, user: user, onSuccess: { (postId) in
            
            // update user-post structure
            let userPostsRef = USER_POSTS_REF.child(user.uid)
            userPostsRef.updateChildValues([postId: 1])
            
            // update user-feed structure
            self.updateUserFeeds(with: postId)
            
            // upload hashtag to server
            if caption.contains("#") {
                self.uploadHashtagToServer(withPostId: postId)
            }
            
            // upload mention notification to server
            if caption.contains("@") {
                self.uploadMentionNotification(forPostId: postId, withText: caption, isForComment: false)
            }
            
            HUD.flash(.success)
            NotificationCenter.default.post(name: .updateHomeFeed, object: nil)
            NotificationCenter.default.post(name: .updateUserProfileFeed, object: nil)
            self.dismiss(animated: true, completion: nil)
        }) { (err) in
            if let error = err {
                print("Failed to upload post:", error)
                return
            }
        }
    }
    
    func shareTextPost(_ user: User) {
        guard let caption = captionTextView.text else { return }
        
        let trimmedCaption = caption.trim()
        
        if trimmedCaption == ""  {
            return
        }
            
        Database.database().createPost(withCaption: trimmedCaption, user: user, onSuccess: { (postId) in
            // update user-post structure
            let userPostsRef = USER_POSTS_REF.child(user.uid)
            userPostsRef.updateChildValues([postId: 1])
            
            // update user-feed structure
            self.updateUserFeeds(with: postId)
            
            // upload hashtag to server
            if caption.contains("#") {
                self.uploadHashtagToServer(withPostId: postId)
            }
            
            // upload mention notification to server
            if caption.contains("@") {
                self.uploadMentionNotification(forPostId: postId, withText: caption, isForComment: false)
            }
            
            NotificationCenter.default.post(name: .updateHomeFeed, object: nil)
            NotificationCenter.default.post(name: .updateUserProfileFeed, object: nil)
            self.dismiss(animated: true, completion: nil)
        }) { (err) in
            if let error = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.captionTextView.isUserInteractionEnabled = true
                print("Failed to upload post:", error)
                return
            }
        }
    }
    
    func updateUserFeeds(with postId: String) {
        guard let currentUid = CURRENT_USER?.uid else { return }
        let values = [postId: 1]
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    
    func uploadHashtagToServer(withPostId postId: String) {
        guard let caption = captionTextView.text else { return }
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private var lastContentOffset: CGFloat = 0
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 {
            UIView.animate(withDuration: 0.7, animations: {
                scrollView.setContentOffset(.zero, animated: false)
            })
        }
    }
    
    func handleShowCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
}
