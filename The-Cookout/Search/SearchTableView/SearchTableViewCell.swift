//
//  SearchTableViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 9/5/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CustomImageView!

    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!

    var delegate: SearchTableCellDelegate?

    var user : User? {
        didSet{
            usernameLabel.text = user?.username
            nameLabel.text = user?.name
            guard let imageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: imageUrl)

            configureFollowedBtn()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
    }

    func configureFollowedBtn() {
        followBtn.layer.cornerRadius = 5
        followBtn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        if user?.uid == Auth.auth().currentUser?.uid {
            followBtn.isHidden = true
            return
        }

        guard let uid = user?.uid else {return}

        DB_REF.database.isFollowingUser(withUID: uid, completion: { (bool) in
            if !bool {
                self.followBtn.setTitle("Following", for: .normal)
            } else {
                self.followBtn.setTitle("Follow", for: .normal)
            }
        }) { (err) in
            print(err)
        }

    }

    @IBAction func followTapped(_ sender: UIButton) {
        delegate?.handleFollowTapped(for: self)
    }
}
