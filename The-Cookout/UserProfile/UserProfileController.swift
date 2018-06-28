//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents
import Lightbox


class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, UserPostCellDelegate, LightboxControllerPageDelegate, LightboxControllerDismissalDelegate, PhotoCellDelegate {
    
    
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
    
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
    
    let refreshControl = UIRefreshControl()
    
    var user: User?
    var userId: String?
    var cellId = "cellId"
    var postCellId = "postCellId"
    
    var isGridView = true
    var gridArray = [Post]()
    var listArray = [Post]()
    
    var postCount = 0
    var followingCount = 0
    var followersCount = 0
    
    var images = [LightboxImage]()
    var indexes = [Int: Int]()
    var currentIndex = 0
    
    func didChangeToGridView() {
        isGridView = true
        handleRefresh()
    }
    
    func didChangeToListView() {
        isGridView = false
        handleRefresh()
    }
    
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PostCell.self, forCellWithReuseIdentifier: postCellId)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(dismissView))
        
        collectionView?.backgroundColor = .white
        
        setupRefresherControl()
        fetchUser()
    }
    
    fileprivate func setupRefresherControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.refreshControl = refreshControl
    }
    
    @objc fileprivate func handleRefresh() {
        self.refreshControl.beginRefreshing()
        self.gridArray.removeAll()
        self.listArray.removeAll()
        self.images.removeAll()
        paginatePosts()
    }
    
    @objc func paginatePosts() {
        
        var count = 10
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        self.refreshControl.endRefreshing()
        
        if isGridView && gridArray.count > 0 {
            let value = self.gridArray.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            count = 12
        } else if !isGridView && listArray.count > 0 {
            let value = self.listArray.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
            count = 12
        }
        
        query.queryLimited(toLast: UInt(count)).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 10 {
                self.isFinishedPaging = true
            }
            
            if self.isGridView {
                if self.gridArray.count > 0 && allObjects.count > 0 {
                    allObjects.removeFirst()
                }
            } else {
                if self.listArray.count > 0 && allObjects.count > 0 {
                    allObjects.removeFirst()
                }
            }
            
            guard let user = self.user else { return }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                
                if post.imageUrl != "" {
                    self.indexes[self.currentIndex] = self.images.count
                    let imageUrl = post.imageUrl
                    let image = LightboxImage(imageURL: URL(string: imageUrl)!)
                    self.images.append(image)
                }
                
                if self.isGridView {
                    self.currentIndex += 1
                }
                
                if post.hasImage == "true" {
                    print(post)
                    self.gridArray.append(post)
                }
                
                if post.hasText == "true" && post.hasImage == "false" {
                    self.listArray.append(post)
                }
            })
            
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func fetchStatsCount() {
        
        guard let uid = self.user?.uid else { return }
        let postsRef = Database.database().reference().child("posts").child(uid)
        postsRef.observe(.value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            self.postCount = allObjects.count
        }
        
        let followingRef = Database.database().reference().child("following").child(uid)
        followingRef.observe(.value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            self.followingCount = allObjects.count
        }
        
        let followersRef = Database.database().reference().child("followers").child(uid)
        followersRef.observe(.value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            self.followersCount = allObjects.count
        }
        
        self.collectionView?.reloadData()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let post = self.gridArray[indexPath.item]
            if post.hasText == "true" && post.hasImage == "false" {
                return .zero
            }
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }
        
        let post = self.listArray[indexPath.item] 
        let estimatedHeight = estimatedHeightForListText(post.caption)
        
        if post.hasImage == "true" {
            var height: CGFloat = 50 + 8 + 8 + estimatedHeight
            height += view.frame.width
            return CGSize(width: view.frame.width, height: height + 72)
        }
        
        return CGSize(width: view.frame.width, height: estimatedHeight + 130)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.delegate = self
            cell.datasourceItem = self.gridArray[indexPath.item]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCell
        cell.delegate = self
        cell.datasourceItem = self.listArray[indexPath.item]
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        header.postCount = self.postCount
        header.followersCount = self.followersCount
        header.followingCount = self.followingCount
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 1 {
            return .zero
        }
        
        guard let user = self.user else { return .zero }
        let estimatedHeight = estimatedHeightForBioText(user.bio)
        return CGSize(width: view.frame.width, height: estimatedHeight + 420)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isGridView {
            return gridArray.count
        }
        
        return listArray.count
    }
    
    private func estimatedHeightForListText(_ text: String) -> CGFloat {
        if text == "" {
            return -15
        }
        let approximateWidthOfTextView = view.frame.width - 12 - 50 - 12 - 2
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font: CustomFont.proximaNovaAlt.of(size: 17.0)!]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    private func estimatedHeightForBioText(_ text: String) -> CGFloat {
        
        if text == "" {
            return 0
        }
        
        let approximateWidthOfTextView = view.frame.width - 12 - 40 - 12 - 2
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    fileprivate func fetchUser() {
        self.navigationItem.title = self.user?.username
        self.collectionView?.reloadData()
        self.fetchStatsCount()
        self.handleRefresh()
    }
    
    func presentLightBox(for cell: UserProfilePhotoCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        let lightboxController = LightboxController(images: images)
        lightboxController.pageDelegate = self
        lightboxController.dismissalDelegate = self
        lightboxController.dynamicBackground = true
        lightboxController.goTo(indexPath.item)
        DispatchQueue.main.async {
            self.present(lightboxController, animated: true, completion: nil)
        }
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: PostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        var post = self.listArray[indexPath.item]
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _) in
            
            if let err = err {
                print("Failed to like post:", err)
                return
            }
            
            print("Successfully liked post.")
            
            post.hasLiked = !post.hasLiked
            
            self.listArray[indexPath.item] = post
            
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isGridView {
            if indexPath.row + 1 == self.gridArray.count && !isFinishedPaging {
                self.paginatePosts()
                return
            }
        } else if !isGridView {
            if indexPath.row + 1 == self.listArray.count && !isFinishedPaging {
                self.paginatePosts()
            }
        }
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
}

