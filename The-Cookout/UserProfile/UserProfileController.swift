//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents


class UserProfileController: HomePostCellViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    let lightboxHeaderTitle: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .white
        return label
    }()
    
    let refreshControl = UIRefreshControl()
    
    var user: User? {
        didSet {
            configureUser()
        }
    }
    
    private var header: UserProfileHeader?
    
    private let alertController: UIAlertController = {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        return ac
    }()
    
    var userId: String?
    
    var isGridView = true
    var listArray = [Post]()
    var gridArray = [Post]()
    
    var isFinishedPagingGrid = false
    var isFinishedPagingList = false

    
    func didChangeToGridView() {
        isGridView = true
        self.collectionView?.setContentOffset(.zero, animated:true)
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        self.collectionView?.setContentOffset(.zero, animated:true)
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func configureUser() {
        guard let user = self.user else { return }
        
        if user.uid == CURRENT_USER?.uid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "follow").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        } else {
            let optionsButton = UIBarButtonItem(title: "•••", style: .plain, target: nil, action: nil)
            optionsButton.tintColor = .black
            navigationItem.rightBarButtonItem = optionsButton
        }
        
        navigationItem.title = user.username
        header?.user = user
        
        handleRefresh()
    }
    
    fileprivate func setupCollectionView() {
        
        collectionView.backgroundColor = .white
        
   //     self.navigationController?.isNavigationBarHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        //Observe refresh
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name.updateUserProfileFeed, object: nil)
        
        // Register header
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeader.cellId)
        collectionView.register(UserBannerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserBannerHeader.cellId)
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: UserProfilePhotoCell.cellId)
        collectionView.register(HomePostTextCell.self, forCellWithReuseIdentifier: HomePostTextCell.cellId)
        collectionView?.register(UserProfileEmptyStateCell.self, forCellWithReuseIdentifier: UserProfileEmptyStateCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.refreshControl = refreshControl
        
        collectionView.contentInsetAdjustmentBehavior = .never
        configureAlertController()
        
        guard let bannerHeader = self.bannerHeader else {return}
        bannerHeader.animator.fractionComplete = 0
    }
    
    private func configureAlertController() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch let err {
                print("Failed to sign out:", err)
            }
        }
        alertController.addAction(logOutAction)
        
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: nil)
        alertController.addAction(deleteAccountAction)
    }
    
    
    @objc private func handleSettings() {
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleRefresh() {
        
        if isGridView {
            isFinishedPagingGrid = false
            gridArray.removeAll()
            paginate(array: gridArray)
        } else {
            isFinishedPagingList = false
            listArray.removeAll()
            paginate(array: listArray)
        }
        
        header?.reloadData()
        bannerHeader?.reloadData()
    }
    
    fileprivate func paginate(array: [Post]) {
        guard let user = self.user else { return }
        
        if isGridView {
            Database.database().queryGrid(forUser: user, posts: array, finishedPaging: isFinishedPagingGrid) { (posts, isPagingDone) in
                self.isFinishedPagingGrid = isPagingDone
                self.gridArray = posts
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
                return
            }
        }
      
        Database.database().queryList(forUser: user, posts: array, finishedPaging: isFinishedPagingList) { (posts, isPagingDone) in
            self.isFinishedPagingList = isPagingDone
            self.listArray = posts
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
        
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfilePhotoCell.cellId, for: indexPath) as! UserProfilePhotoCell
            cell.delegate = self as? PhotoCellDelegate
            cell.datasourceItem = self.gridArray[indexPath.item]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostTextCell.cellId, for: indexPath) as! HomePostTextCell
        cell.delegate = self
        cell.post = self.listArray[indexPath.item]
        return cell
    }
    
    var bannerHeader: UserBannerHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let section = indexPath.section
            
            switch section {
            case 0:
                if bannerHeader == nil {
                    bannerHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserBannerHeader.cellId, for: indexPath) as? UserBannerHeader
                    bannerHeader?.clipsToBounds = false
                    bannerHeader?.user = self.user
                    bannerHeader?.delegate = self
                }
                return bannerHeader!
            default:
                if header == nil {
                    header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserProfileHeader.cellId, for: indexPath) as? UserProfileHeader
                    header?.clipsToBounds = false
                    header?.user = self.user
                    header?.delegate = self
                }
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
    
    func didTapImage(_ post: Post) {
        let commentsController = CommentsController()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isGridView {
            if indexPath.row + 1 == self.gridArray.count && !isFinishedPagingGrid {
                self.paginate(array: gridArray)
                return
            }
        } else if !isGridView {
            if indexPath.row + 1 == self.listArray.count && !isFinishedPagingList {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let post = self.gridArray[indexPath.item]
            
            if !post.hasImage  {
                return .zero
            }
            
            let width = (view.frame.width - 2) / 3
            
            return CGSize(width: width, height: width)
        }
        
        let post = self.listArray[indexPath.item]
        let estimatedHeight = estimatedHeightForListText(post.caption)
        
        if post.hasImage {
            return .zero
        }
        
        return CGSize(width: view.frame.width, height: estimatedHeight + 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: view.frame.width, height: 160)
        }
        
        guard let user = self.user else { return .zero }
        let estimatedHeight = estimatedHeightForBioText(user.bio)
        return CGSize(width: view.frame.width, height: estimatedHeight + 260)
    }
    
    let bannerStopAtOffset:CGFloat = 200 - 64
    let distanceBetweenTopAndHeader:CGFloat = 30.0
    let scrollToScaleDownProfileIconDistance: CGFloat = 60
    
    var lastContentOffset: CGFloat = 0
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    let maxHeight: CGFloat = 120
    let minHeight: CGFloat = 60
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let header = self.header else {return}
        guard let bannerHeader = self.bannerHeader else {return}
        
        let contentOffsetY = scrollView.contentOffset.y
        
        let halfFrameWidth = header.frame.width / 2.0
        let halfImageViewWidth = header.profileImageView.frame.width / 2
        let centerX = (halfFrameWidth - halfImageViewWidth)
        
        let scaleProgress = max(0, min(1, contentOffsetY / self.scrollToScaleDownProfileIconDistance))
        let height = max(maxHeight - (maxHeight - minHeight) * scaleProgress, minHeight)
        
        bannerHeader.animator.fractionComplete = (abs(contentOffsetY) * 2) / 100
        
        if header.profileImageView.layer.zPosition < bannerHeader.layer.zPosition {
            bannerHeader.layer.zPosition = 0
        }
        
        if contentOffsetY < 0 {
            bannerHeader.animator.fractionComplete = (abs(contentOffsetY) * 2) / 100
//            bannerHeader.animator.fractionComplete = (abs(contentOffsetY) * 2) / 100
//            header.profileImageView.frame = CGRect(x: centerX, y: -60, width: maxHeight, height: maxHeight)
//            header.profileImageView.layer.cornerRadius = height / 2

        } else if contentOffsetY >= 0 && contentOffsetY <= scrollToScaleDownProfileIconDistance && scaleProgress <= 1 {

//            header.profileImageView.frame = CGRect(x: centerX, y: contentOffsetY - 60, width: height, height: height)
//            header.profileImageView.layer.cornerRadius = height / 2

//            bannerHeader.animator.fractionComplete = 0
            
            bannerHeader.animator.fractionComplete = 0

            return
        } else {
            //   bannerHeader.animator.fractionComplete = 0
//            if header.profileImageView.layer.zPosition >= bannerHeader.layer.zPosition {
//                bannerHeader.layer.zPosition = 2
//            }
        }
    }
    
    
}
