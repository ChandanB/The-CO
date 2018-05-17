//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents
import GSKStretchyHeaderView

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class UserProfileController: DatasourceController, GSKStretchyHeaderViewStretchDelegate {
    
    func stretchyHeaderView(_ headerView: GSKStretchyHeaderView, didChangeStretchFactor stretchFactor: CGFloat) {
        print ("Header changed")
    }
    
    let userProfileDatasource = UserProfileDataSource()
    var userProfileHeader = UserProfileHeader()
    
    var userId: String?
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datasource = self.userProfileDatasource
        
        collectionView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView?.backgroundColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        fetchUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Header - Image
        headerImageView = self.userProfileHeader.bannerImageView
        headerImageView?.image = UIImage(named: "header_bg")
        headerImageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.userProfileHeader.insertSubview(headerImageView, belowSubview: headerLabel)
        
        // Header - Blurred Image
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let headerBlurImageView = UIVisualEffectView(effect: blurEffect)
        headerBlurImageView.frame = view.bounds
        headerBlurImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerBlurImageView.contentMode = UIViewContentMode.scaleAspectFill
        headerBlurImageView.alpha = 0.0
        self.userProfileHeader.insertSubview(headerBlurImageView, belowSubview: headerLabel)
        
        self.userProfileHeader.clipsToBounds = true
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid else {return}
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
            self.navigationItem.title = self.user?.name
            self.collectionView?.reloadData()
            self.fetchOrderedPosts()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        self.userProfileHeader = header
        
        return userProfileHeader
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 420)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = UIColor.white
    }
    
    var scrollView:UIScrollView!
    var avatarImage:UIImageView!
    var headerLabel:UILabel!
    var headerImageView:UIImageView!
    var headerBlurImageView:UIImageView!
    var blurredHeaderImageView:UIImageView?
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        avatarImage = self.userProfileHeader.profileImageView
        headerLabel = self.userProfileHeader.usernameLabel
        headerImageView = self.userProfileHeader.bannerImageView
        headerBlurImageView = self.userProfileHeader.bannerImageView
        blurredHeaderImageView = self.userProfileHeader.bannerImageView
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            let headerScaleFactor:CGFloat = -(offset) / self.userProfileHeader.bounds.height
            let headerSizevariation = (((self.userProfileHeader.bounds.height) * (1.0 + headerScaleFactor)) - (self.userProfileHeader.bounds.height))/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            self.userProfileHeader.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            headerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if avatarImage.layer.zPosition < (self.userProfileHeader.layer.zPosition){
                    self.userProfileHeader.layer.zPosition = 0
                }
                
            }else {
                if avatarImage.layer.zPosition >= (self.userProfileHeader.layer.zPosition){
                    self.userProfileHeader.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        
        self.userProfileHeader.layer.transform = headerTransform
        avatarImage.layer.transform = avatarTransform
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
}

