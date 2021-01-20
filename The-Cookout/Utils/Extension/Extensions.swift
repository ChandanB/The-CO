//
//  Extensions.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import UIFontComplete

extension UIButton {

    func configure(didFollow: Bool) {
        if didFollow {
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white

        } else {
            // handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}

enum CustomFont: String, FontRepresentable {
    case proximaNova = "Proxima Nova"
    case proximaNovaAlt = "ProximaNovaA-Regular"
    case proximaNovaCondensed = "ProximaNovaACond-Semibold"
    case proximaNovaSemibold = "ProximaNova-Semibold"
    case proximaNovaThin = "ProximaNovaT-Thin"
    case proximaNovaScOsf = "ProximaNovaS-Thin"
    case proximaNovaBold = "ProximaNovaA-Bold"
    case proximaNovaBlack = "ProximaNovaA-Black"
}

//for avatars
func dataImageFromString(pictureString: String, withBlock: (_ image: Data?) -> Void) {
    let imageData = NSData(base64Encoded: pictureString, options: NSData.Base64DecodingOptions(rawValue: 0))
    withBlock(imageData as Data?)
}

func timeElapsed(date: Date) -> String {

    let seconds = NSDate().timeIntervalSince(date)
    var elapsed: String?

    if (seconds < 60) {
        elapsed = "Just now"
    } else if (seconds < 60 * 60) {
        let minutes = Int(seconds / 60)

        var minText = "min"
        if minutes > 1 {
            minText = "mins"
        }
        elapsed = "\(minutes) \(minText)"

    } else if (seconds < 24 * 60 * 60) {
        let hours = Int(seconds / (60 * 60))
        var hourText = "hour"
        if hours > 1 {
            hourText = "hours"
        }
        elapsed = "\(hours) \(hourText)"
    } else {
        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "dd/MM/YYYY"

        elapsed = "\(currentDateFormater.string(from: date))"
    }

    return elapsed!
}

func formatCallTime(date: Date) -> String {
    let seconds = NSDate().timeIntervalSince(date)
    var elapsed: String?

    if (seconds < 60) {
        elapsed = "Just now"
    } else if (seconds < 24 * 60 * 60) {

        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "HH:mm"

        elapsed = "\(currentDateFormater.string(from: date))"
    } else {
        let currentDateFormater = dateFormatter()
        currentDateFormater.dateFormat = "dd/MM/YYYY"

        elapsed = "\(currentDateFormater.string(from: date))"
    }

    return elapsed!
}

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
      view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
      view.endEditing(true)
    }

    func getMentionedUser(withUsername username: String) {
        USERS_REF.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key

            USERS_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }

                if username == dictionary["username"] as? String {
                    Database.database().fetchUser(withUID: uid, completion: { (user) in
                        let userProfileController = UserProfileController(collectionViewLayout: StretchyHeaderLayout())
                        userProfileController.user = user
                        self.navigationController?.pushViewController(userProfileController, animated: true)
                        return
                    })
                }
            })
        }
    }

    func uploadMentionNotification(forPostId postId: String, withText text: String, isForComment: Bool) {
        guard let currentUid = CURRENT_USER?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let words = text.components(separatedBy: .whitespacesAndNewlines)

        var mentionIntegerValue: Int!
        if isForComment {
            mentionIntegerValue = COMMENT_MENTION_INT_VALUE
        } else {
            mentionIntegerValue = POST_MENTION_INT_VALUE
        }
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .symbols)
                word = word.trimmingCharacters(in: .punctuationCharacters)

                USERS_REF.observe(.childAdded, with: { (snapshot) in
                    let uid = snapshot.key
                    USERS_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                        if word == dictionary["username"] as? String {
                            let notificationValues = ["postId": postId,
                                                      "uid": currentUid,
                                                      "type": mentionIntegerValue,
                                                      "creationDate": creationDate] as [String: Any]

                            if currentUid != uid {
                                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
                            }
                        }
                    })
                })
            }
        }
    }

    func hideNavigationBar() {
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }

    func showNavigationBar() {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

extension Array where Element: Equatable {

    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
            return true
        }
        return false
    }

    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.firstIndex(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }

}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.width)
    }
}

extension NSNotification.Name {
    static let updateHomeFeed = NSNotification.Name(Bundle.main.bundleIdentifier! + ".updateHomeFeed")
    static let updateUserProfileFeed = NSNotification.Name(Bundle.main.bundleIdentifier! + ".updateUserProfileFeed")
}

// MARK: GLOBAL FUNCTIONS
private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void) {
    var image: UIImage?
    let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
    image = UIImage(data: decodedData! as Data)
    withBlock(image)
}
