//
//  HashTagController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/7/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "HashtagCell"

class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properites

    var posts = [Post]()
    var hashtag: String?

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()

        collectionView?.backgroundColor = .white
        collectionView?.register(HashtagCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        fetchPosts()
    }

    // MARK: - UICollectionViewFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCell

        cell.post = posts[indexPath.item]

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let homeController = HomeController(collectionViewLayout: UICollectionViewFlowLayout())
        homeController.viewSinglePost = true
        homeController.post = posts[indexPath.item]
        navigationController?.pushViewController(homeController, animated: true)
    }

    // MARK: - Handlers

    func configureNavigationBar() {
        guard let hashtag = self.hashtag else { return }
        navigationItem.title = hashtag
    }

    // MARK: - API

    func fetchPosts() {
        guard let hashtag = self.hashtag else { return }

        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { (snapshot) in

            let postId = snapshot.key

            POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                if let userId = dictionary["uid"] {
                    DB_REF.database.fetchUser(withUID: userId as! String, completion: { (user) in
                        let post = Post(id: postId, user: user, dictionary: dictionary)
                        self.posts.append(post)
                        self.collectionView?.reloadData()
                    })
                }
            }
        }
    }

}
