//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents

class UserProfileController: DatasourceController {
    
    var isGridView = true
    
    func didChangeToGridView(_ user: User) {
        isGridView = true
        self.collectionView?.reloadData()
    }
    
    func didChangeToListView(_ user: User) {
        isGridView = false
        self.collectionView?.reloadData()
    }
    
    let userProfileDatasource = UserProfileDatasource()
    
    var userId: String?
    var cellId = "cellId"
    var postCellId = "postCellId"
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PostCell.self, forCellWithReuseIdentifier: postCellId)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(dismissView))
        
        collectionView?.backgroundColor = .white
        
        self.datasource = self.userProfileDatasource
        
        fetchUser()
        
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func paginatePosts() {
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrderedByKey()
        
        if isGridView {
            
            if self.userProfileDatasource.gridData.count > 0 {
                let value = self.userProfileDatasource.gridData.last?.id
                query = query.queryStarting(atValue: value)
                paginateGridPost(query)
            } else {
                paginateGridPost(query)
            }
            
            return
        }
        
        if self.userProfileDatasource.listData.count > 0 {
            let value = self.userProfileDatasource.listData.last?.id
            query = query.queryStarting(atValue: value)
            paginateListPost(query)
        } else {
            paginateListPost(query)
        }
        
    }
    
    fileprivate func paginateGridPost(_ query: DatabaseQuery) {
        query.queryLimited(toFirst: 6).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if allObjects.count < 6 {
                self.isFinishedPaging = true
            }
            if self.userProfileDatasource.gridData.count > 0 {
                allObjects.removeFirst()
            }
            guard let user = self.user else { return }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                post.id = snapshot.key
                
                if post.hasImage == "true" {
                    self.userProfileDatasource.gridData.append(post)
                }
            })
            
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func paginateListPost(_ query: DatabaseQuery) {
        query.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if allObjects.count < 20 {
                self.isFinishedPaging = true
            }
            if self.userProfileDatasource.listData.count > 0 {
                allObjects.removeFirst()
            }
            guard let user = self.user else { return }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                post.id = snapshot.key
                
                if post.hasText == "true" {
                    self.userProfileDatasource.listData.append(post)
                }
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    var user: User?
    fileprivate func fetchUser() {
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.userProfileDatasource.user = user
            self.navigationItem.title = self.user?.name
            self.userProfileDatasource.gridData.removeAll()
            self.userProfileDatasource.listData.removeAll()
            self.collectionView?.reloadData()
            self.paginatePosts()
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
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }
        
        guard let post = self.datasource?.item(indexPath) as? Post else { return .zero }
        let estimatedHeight = estimatedHeightForListText(post.caption)
        
        if post.imageWidth.intValue > 0 {
            var height: CGFloat = 50 + 8 + 8 + estimatedHeight
            height += view.frame.width
            return CGSize(width: view.frame.width, height: height + 72)
        }
        return CGSize(width: view.frame.width, height: estimatedHeight + 126)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            if indexPath.item == self.userProfileDatasource.gridData.count - 1 && !isFinishedPaging {
                print("Paginating for posts")
                paginatePosts()
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.datasourceItem = self.userProfileDatasource.gridData[indexPath.item]
            return cell
        }
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCell
        cell.datasourceItem = self.userProfileDatasource.gridData[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 1 {
            return .zero
        }
        
        guard let user = self.user else { return .zero }
        let estimatedHeight = estimatedHeightForBioText(user.bio)
        return CGSize(width: view.frame.width, height: estimatedHeight + 420)
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
    
    func didLike(for cell: UserProfileTextCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        var post = self.userProfileDatasource.gridData[indexPath.item]
        
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
            
            self.userProfileDatasource.gridData[indexPath.item] = post
            
            self.collectionView?.reloadItems(at: [indexPath])
            
        }
    }
    
}

