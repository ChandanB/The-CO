//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents

let offset_HeaderStop:CGFloat = 60.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class UserProfileController: DatasourceController {
    
    let userProfileDatasource = UserProfileDataSource()
    var userProfileHeader = UserProfileHeader()
    
    var avatarImage:UIImageView!
    var headerLabel:UILabel!
    var header: UIView!
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    var blurredHeaderImageView:UIImageView!
    
    var userId: String?
    var headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView?.backgroundColor = .white
        self.datasource = self.userProfileDatasource
        
        fetchUser()
        header = userProfileHeader
        avatarImage = userProfileHeader.profileImageView
        headerLabel = userProfileHeader.usernameLabel
        headerImageView = userProfileHeader.bannerImageView
        headerBlurImageView = userProfileHeader.blurredBannerImageView
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        self.header = header

        self.userProfileHeader = header

        return header
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        header = userProfileHeader
        avatarImage = userProfileHeader.profileImageView
        headerLabel = userProfileHeader.usernameLabel
        headerImageView = userProfileHeader.bannerImageView
        headerBlurImageView = userProfileHeader.blurredBannerImageView
    }
    
    fileprivate func fetchOrderedPosts(_ user: User) {
        let uid = user.uid
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            
            let post = Post(user: user, dictionary: dictionary as [String : AnyObject])
            
            if post.imageUrl != "" {
                self.userProfileDatasource.posts.insert(post, at: 0)
                self.collectionView?.reloadData()
            }
        }
    }
    
    var user: User?
    fileprivate func fetchUser() {
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.userProfileDatasource.users.append(user)
            self.userProfileHeader.datasourceItem = user
            
            self.navigationItem.title = self.user?.name
            self.collectionView?.reloadData()
            self.fetchOrderedPosts(user)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 1 {
            return .zero
        }
        
        return CGSize(width: view.frame.width, height: 160)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: 290)
        }
        
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        var labelTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        var frame = self.collectionView?.frame
        
        if offset < 0 {

//            frame?.origin.y = min(0, offset)
//            self.header.frame = frame!

            let headerScaleFactor: CGFloat = -(offset) / (header.frame.height)
            let headerSizevariation = (((header.bounds.height) * (1.0 + headerScaleFactor)) - (header.bounds.height))/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)

            header.layer.transform = headerTransform
            
    
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (0.8, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < (headerImageView.layer.zPosition){
                    headerImageView.layer.zPosition = 0
                }
                
            }else {
                if avatarImage.layer.zPosition >= (headerImageView.layer.zPosition){
                    headerImageView.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        header.layer.transform = headerTransform
        headerLabel.layer.transform = labelTransform
        avatarImage.layer.transform = avatarTransform
        
        
    }
    
    private var lastContentOffset: CGFloat = 0

}

