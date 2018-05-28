//
//  Color.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/21/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

let twitterBlue = UIColor(r: 55, g: 115, b: 210)

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}
