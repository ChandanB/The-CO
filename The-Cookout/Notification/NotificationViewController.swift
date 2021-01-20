//
//  NotificationViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/6/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationViewController: UITableViewController, NotificationCellDelegate {

    // MARK: - Properties

    var timer: Timer?
    var currentKey: String?

    var notifications = [NotificationModel]()
    private let initialPostsCount: UInt = 20
    private let furtherPostsCount: UInt = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        //clear seperator lines
        tableView.separatorColor = .clear

        //register Cell Class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)

        //navigation title
        navigationItem.title = "Notifications"

        //fetch notification
        fetchNotifications()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if notifications.count > 4 {
            if indexPath.item == notifications.count - 1 {
                self.fetchNotifications()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let userProfileVC = UserProfileController(collectionViewLayout: StretchyHeaderLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)

    }

    // MARK: - notification cell delegate protocol

    func followTapped(for cell: NotificationCell) {
        guard let getUser = cell.notification?.user else {return}
        var user = getUser

        if user.isFollowing {
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            user.follow()
            cell.followButton.configure(didFollow: true)
        }

    }

    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else {return}
        let homeController = HomeController(collectionViewLayout: UICollectionViewFlowLayout())
        homeController.viewSinglePost = true
        homeController.post = post
        navigationController?.pushViewController(homeController, animated: true)
    }

    // MARK: - Handlers

    func handleReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotification), userInfo: nil, repeats: false)

    }

    @objc func handleSortNotification() {

        self.notifications.sort { (notification1, notification2) -> Bool in

            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }

    // MARK: - API

    func fetchNotifications() {

        guard let currentUid = CURRENT_USER?.uid else {return}

        if currentKey == nil {
            NOTIFICATIONS_REF.child(currentUid).queryLimited(toLast: initialPostsCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                let first = allObjects.first

                for object in allObjects {
                    guard let dict = object.value as? [String:Any] else {return}
                    guard let uid = dict["uid"] as? String else {return}
                    self.fetchNotification(uid: uid, dict: dict)
                    NOTIFICATIONS_REF.child(currentUid).child(object.key).child("checked").setValue(1)
                }
                self.currentKey = first?.key
            }
        } else {
            NOTIFICATIONS_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: currentKey).queryLimited(toLast: furtherPostsCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                let first = allObjects.first

                for object in allObjects {
                    guard let dict = object.value as? [String:Any] else {return}
                    guard let uid = dict["uid"] as? String else {return}
                    if object.key == self.currentKey {continue}
                    self.fetchNotification(uid: uid, dict: dict)
                    NOTIFICATIONS_REF.child(currentUid).child(object.key).child("checked").setValue(1)
                }
                self.currentKey = first?.key
            }
        }
    }

    func fetchNotification(uid: String, dict: [String:Any]) {
        DB_REF.database.fetchUser(withUID: uid) { (user) in
            var notification : NotificationModel?
            if let postId = dict["id"] as? String {
                DB_REF.database.fetchPost(with: postId, user: user, completion: { (post) in
                    notification = NotificationModel(user: user, post: post, dictionary: dict as Dictionary<String, AnyObject>)
                    self.notifications.append(notification!)
                    self.handleReloadTable()
                })
            } else {
                notification = NotificationModel(user: user, dictionary: dict as Dictionary<String, AnyObject>)
                self.notifications.append(notification!)
                self.handleReloadTable()
            }
        }
    }
}
