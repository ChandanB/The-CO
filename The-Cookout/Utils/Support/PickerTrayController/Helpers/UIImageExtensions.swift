//
//  UIImageExtensions.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//


import UIKit

extension UIImage {
    
    convenience init?(bundledName name: String) {
        let bundle = Bundle(for: ImagePickerTrayController.self)
        self.init(named: name, in: bundle, compatibleWith:nil)
    }
    
}
