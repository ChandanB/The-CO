//
//  UIButton+Extension.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

extension UIButton {
    func addLeftPadding(_ padding: CGFloat) {
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: padding, bottom: 0.0, right: -padding)
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: padding)
    }

    convenience init(withImage image: UIImage, title: String) {
        self.init()

        setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        imageView?.tintColor = fbDarkGray
        imageView?.contentMode = .scaleAspectFit
        semanticContentAttribute = .forceLeftToRight

        setTitle(title, for: .normal)
        titleLabel?.textColor = fbDarkGray
        setTitleColor(fbDarkGray, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)

        imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        //        addLeftPadding(3)
    }
}
