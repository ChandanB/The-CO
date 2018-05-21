//
//  UserProfileController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents


class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate, UserProfileTextDelegate {
    
    var userId: String?
    var cellId = "cellId"
    var postCellId = "postCellId"
    
    var isGridView = true
    
    var gridArray = [Post]()
    var listArray = [Post]()
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PostCell.self, forCellWithReuseIdentifier: postCellId)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(dismissView))
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    
    fileprivate func paginatePosts() {
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if isGridView && gridArray.count > 0 {
            let value = self.gridArray.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        } else if !isGridView && listArray.count > 0 {
            let value = self.listArray.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 12).observe(.value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 12 {
                self.isFinishedPaging = false
            }
            
            if self.isGridView && self.gridArray.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            } else if self.isGridView == false && self.listArray.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            guard let user = self.user else { return }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary as [String : AnyObject])
                post.id = snapshot.key
                
                if post.hasImage == "true" {
                    self.gridArray.append(post)
                }
                
                if post.hasText == "true" {
                    self.listArray.append(post)
                }
                
            })
                
            self.collectionView?.reloadData()
        }
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
                if indexPath.item == self.gridArray.count - 1 && isFinishedPaging {
                    paginatePosts()
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
                cell.datasourceItem = self.gridArray[indexPath.item]
                return cell
            }
            
            if indexPath.item == self.listArray.count - 1 && isFinishedPaging {
                paginatePosts()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCell
            cell.datasourceItem = self.listArray[indexPath.item]
            return cell
            
        }
        
        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
            
            header.user = self.user
            header.delegate = self
            
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
        
        var user: User?
        fileprivate func fetchUser() {
            let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.user = user
                self.navigationItem.title = self.user?.name
                self.collectionView?.reloadData()
                self.paginatePosts()
            }
        }
        
        func didLike(for cell: UserProfileTextCell) {
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
                fetchAllPosts()
            }
        } else {
            if indexPath.row + 1 == self.listArray.count && !isFinishedPaging {
                fetchAllPosts()
            }
        }
    }
        
}

