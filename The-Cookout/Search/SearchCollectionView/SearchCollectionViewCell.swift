//
//  SearchCollectionViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 9/5/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImageView: CustomImageView!

    var post : Post? {
        didSet{
            guard let imageUrl = post?.imageUrl else { return }
            postImageView.loadImage(urlString: imageUrl)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
