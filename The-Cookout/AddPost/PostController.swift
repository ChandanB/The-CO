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

class PostController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ReturnPostImageDelegate, ReturnPostTextDelegate {
    
    let cellId = "cellId"
    let headerId = "headerId"
    var user: User?
    
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
   
//    func handleOpenPhotoSelector() {
//        let layout = UICollectionViewFlowLayout()
//        self.photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
//        self.photoSelectorController?.delegate = self
//        let navController = UINavigationController(rootViewController: photoSelectorController!)
//        self.present(navController, animated: true, completion: nil)
//    }
    
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
    
    
    func handleShowCamera() {
        
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
        
        guard let image = selectedImage else { return }
        guard let caption = captionTextView.text else { return }
        
        var trimmedCaption = caption.trim()
        
        if trimmedCaption == "What's on your mind?" || trimmedCaption == "Say something about this picture?" {
            trimmedCaption = ""
        }
        
        Database.database().createImagePost(withImage: image, caption: trimmedCaption, user: user, onSuccess: {
            HUD.flash(.success)
            NotificationCenter.default.post(name: NSNotification.Name.updateHomeFeed, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.updateUserProfileFeed, object: nil)
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
            
        Database.database().createPost(withCaption: trimmedCaption, user: user, onSuccess: {
            NotificationCenter.default.post(name: NSNotification.Name.updateHomeFeed, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.updateUserProfileFeed, object: nil)
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
    
//    func handleShowCamera() {
//        Config.tabsToShow = [.cameraTab]
//        Config.Camera.imageLimit = 1
//        Config.VideoEditor.maximumDuration = 30
//        Config.VideoEditor.savesEditedVideoToLibrary = true
//        let cameraController = GalleryController()
//        cameraController.delegate = self
//        self.present(cameraController, animated: true, completion: nil)
//    }
    
//    func handleOpenGallery() {
//        Config.tabsToShow = [.imageTab, .videoTab]
//        Config.Camera.imageLimit = 1
//        let cameraController = GalleryController()
//        cameraController.delegate = self
//        self.present(cameraController, animated: true, completion: nil)
//    }
    
    //    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    //        let image = images[0]
    //        image.resolve { (image) in
    //            self.selectedImage = image
    //        }
    //        dismiss(animated: true, completion: nil)
    //    }
    //
    //    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    //        dismiss(animated: true, completion: nil)
    //
    //        let editor = AdvancedVideoEditor()
    //        editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
    //            DispatchQueue.main.async {
    //                if let tempPath = tempPath {
    //                    let controller = AVPlayerViewController()
    //                    controller.player = AVPlayer(url: tempPath)
    //
    //                    self.present(controller, animated: true, completion: nil)
    //                }
    //            }
    //        }
    //    }
    //
    //    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    //
    //    }
    //
    //    func galleryControllerDidCancel(_ controller: GalleryController) {
    //          dismiss(animated: true, completion: nil)
    //    }
    
}
