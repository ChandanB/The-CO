//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents
import PinterestLayout
import AlamofireImage


class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, UserPostCellDelegate, PinterestLayoutDelegate {
    
    let lightboxHeaderTitle: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .white
        return label
    }()
    
    let refreshControl = UIRefreshControl()
    
    var user: User?
    var userId: String?
    var cellId = "cellId"
    var postCellId = "postCellId"
    var headerOne = "headerId1"
    var headerTwo = "headerId2"
    
    
    var isGridView = true
    var gridArray = [Post]()
    var listArray = [Post]()
    
    var postCount = 0
    var followingCount = 0
    var followersCount = 0
    
    var indexes = [Int: Int]()
    var currentIndex = 0
    
    
    func didChangeToGridView() {
        isGridView = true
        paginate(array: gridArray)
    }
    
    func didChangeToListView() {
        isGridView = false
        paginate(array: listArray)
    }
    
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupRefresherControl()
        fetchUser()
    }
    
    fileprivate func setupCollectionView() {
        self.navigationController?.isNavigationBarHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(dismissView))
        
        //Observe refresh
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        
        // Register header
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerOne)
        collectionView.register(UserBannerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerTwo)
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: postCellId)
        
        
        collectionView.backgroundColor = .white
        self.view.backgroundColor = .red
        
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    fileprivate func setupRefresherControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.refreshControl = refreshControl
    }
    
    @objc fileprivate func handleRefresh() {
        self.refreshControl.beginRefreshing()
        self.isFinishedPaging = false
        
        self.currentIndex = 0
        
        if isGridView {
            self.gridArray.removeAll()
            paginate(array: gridArray)
        } else {
            self.listArray.removeAll()
            paginate(array: listArray)
        }
    }
    
    var currentArray = 0
    
    fileprivate func paginate(array: [Post]) {
        self.refreshControl.endRefreshing()
        
        if isGridView {
            currentArray = 0
        } else {
            currentArray = 1
        }
        
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        switch currentArray {
            
        case 0:
            var gridCount = 6
            if gridArray.count > 0 {
                let value = self.gridArray.last?.creationDate.timeIntervalSince1970
                query = query.queryEnding(atValue: value)
                gridCount = 8
            }
            
            query.queryLimited(toLast: UInt(gridCount)).observeSingleEvent(of: .value) { (snapshot) in
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.reverse()
                
                if allObjects.count < 6 {
                    self.isFinishedPaging = true
                }
                
                if self.gridArray.count > 0 && allObjects.count > 0 {
                    allObjects.removeFirst()
                }
                
                guard let user = self.user else { return }
                
                allObjects.forEach({ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                    
                    if post.hasImage == "true" {
                        self.gridArray.append(post)
                        // let imageUrl = post.imageUrl
                        // self.currentIndex += 1
                    }
                    
                })
                
                self.collectionView?.reloadData()
                return
            }
            
        default:
            var listCount = 10
            if listArray.count > 0 {
                let value = self.listArray.last?.creationDate.timeIntervalSince1970
                query = query.queryEnding(atValue: value)
                listCount = 12
            }
            
            query.queryLimited(toLast: UInt(listCount)).observeSingleEvent(of: .value) { (snapshot) in
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.reverse()
                
                if allObjects.count < 10 {
                    self.isFinishedPaging = true
                }
                
                if self.listArray.count > 0 && allObjects.count > 0 {
                    allObjects.removeFirst()
                }
                
                guard let user = self.user else { return }
                
                allObjects.forEach({ (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                    
                    if post.hasText == "true" && post.hasImage == "false" {
                        self.listArray.append(post)
                    }
                })
                self.collectionView?.reloadData()
            }
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
            
            //            let h = CGFloat(truncating: post.imageHeight)
            //            let w = CGFloat(truncating: post.imageWidth)
            
            if post.hasText == "true" && post.hasImage == "false" {
                return .zero
            }
            let width = (view.frame.width - 2) / 3
            
            //            let height = h * width / w
            
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
            cell.delegate = self as? PhotoCellDelegate
            cell.datasourceItem = self.gridArray[indexPath.item]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCell
        cell.delegate = self
        cell.datasourceItem = self.listArray[indexPath.item]
        return cell
        
    }
    
    
    var header: UserProfileHeader?
    var bannerHeader: UserBannerHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let section = indexPath.section
            
            switch section {
            case 0:
                bannerHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerTwo, for: indexPath) as? UserBannerHeader
                bannerHeader?.user = self.user
                bannerHeader?.delegate = self
                
                return bannerHeader!
            default:
                header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerOne, for: indexPath) as? UserProfileHeader
                
                header?.clipsToBounds = false
                header?.user = self.user
                header?.delegate = self
                header?.postCount = self.postCount
                header?.followersCount = self.followersCount
                header?.followingCount = self.followingCount
                
                return header!
            }
            
        default:
            return UserProfileHeader()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var edgeInsets = UIEdgeInsets()
        
        if section == 0 {
            edgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
            return edgeInsets
        }
        
        edgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        
        return edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: view.frame.width, height: 160)
        }
        
        guard let user = self.user else { return .zero }
        let estimatedHeight = estimatedHeightForBioText(user.bio)
        return CGSize(width: view.frame.width, height: estimatedHeight + 260)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 0
        }
        
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
        let attributes = [NSAttributedString.Key.font: CustomFont.proximaNovaAlt.of(size: 17.0)!]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    private func estimatedHeightForBioText(_ text: String) -> CGFloat {
        
        if text == "" {
            return 0
        }
        
        let approximateWidthOfTextView = view.frame.width - 12 - 40 - 12 - 2
        let size = CGSize(width: approximateWidthOfTextView, height: 1000)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return estimatedFrame.height
    }
    
    fileprivate func fetchUser() {
        self.navigationItem.title = self.user?.username
        self.collectionView?.reloadData()
        self.fetchStatsCount()
        self.handleRefresh()
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapImage(_ post: Post) {
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
                self.paginate(array: gridArray)
                return
            }
        } else if !isGridView {
            if indexPath.row + 1 == self.listArray.count && !isFinishedPaging {
                self.paginate(array: listArray)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        let post = gridArray[indexPath.item]
        
        let h = CGFloat(truncating: post.imageHeight)
        let w = CGFloat(truncating: post.imageWidth)
        let size = h * view.frame.width / w
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        return 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    let bannerStopAtOffset:CGFloat = 200 - 64
    let distanceBetweenTopAndHeader:CGFloat = 30.0
    
    var lastContentOffset: CGFloat = 0
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    var headerXOriginal: CGFloat = 0.0
    var index = 0
    let scrollToScaleDownProfileIconDistance: CGFloat = 0
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = self.header else {return}
        guard let bannerHeader = self.bannerHeader else {return}
        
        var headerX: CGFloat = 0
        let contentOffsetY = scrollView.contentOffset.y
        
        let scaleProgress = max(0, min(1, contentOffsetY / self.scrollToScaleDownProfileIconDistance))
        let height = header.profileImageView.bounds.height
        let width = header.profileImageView.bounds.width
        header.animate(t: scaleProgress)
        
        if index == 0 {
            headerX = header.profileImageView.frame.minX
            self.headerXOriginal = headerX
        }
        
        self.index = 1
        
        if contentOffsetY > 0 && contentOffsetY < 50 {
            UIView.animate(withDuration: 0.6, animations: {
              //  header.profileImageView.center.y = contentOffsetY
             //   header.profileImageView.frame = CGRect(x: self.headerXOriginal, y: contentOffsetY, width: width, height: height)
            })
        }
        
        
        if contentOffsetY > 0 {
            if contentOffsetY >= scrollToScaleDownProfileIconDistance {
            //    scrollView.bringSubviewToFront(bannerHeader)
                bannerHeader.animator.fractionComplete = 0
                return
            }
        }
        
        if contentOffsetY <= 0 {
         //   scrollView.bringSubviewToFront(header)
            bannerHeader.animator.fractionComplete = (abs(contentOffsetY) * 2) / 180
        }
        
    }
    
}


//    fileprivate func refreshPosts() {
//        refreshControl.endRefreshing()
//
//        guard let user = self.user else {return}
//
//        let uid = user.uid
//
//        let ref = Database.database().reference().child("posts").child(uid)
//        let query = ref.queryOrdered(byChild: "creationDate")
//
//        query.queryLimited(toFirst: 1).observe( .value) { (snapshot) in
//            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
//
//            allObjects.reverse()
//
//            allObjects.forEach({ (snapshot) in
//                guard (snapshot.value as? [String: Any]) != nil else { return }
//            //  let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
//
//            })
//        }
//    }
