//
//  StretchyHeaderLayout.swift
//  The-Cookout
//
//  Created by Chandan Brown on 4/9/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class StretchyHeaderLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let sectionsToAdd = NSMutableIndexSet()
        var newLayoutAttributes = [UICollectionViewLayoutAttributes]()

        layoutAttributes.forEach({ (attributes) in
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader && attributes.indexPath.section == 0 {
                
                guard let collectionView = collectionView else { return }
                
                let indexPath = attributes.indexPath

                let contentOffsetY = collectionView.contentOffset.y
                
                let width = collectionView.frame.width
                let height = attributes.frame.height - (contentOffsetY)
                
//                let minimum: CGFloat = 0
//                let maximum: CGFloat = 160.0
//                
//                if contentOffsetY < minimum {
//                    attributes.frame.origin.y = minimum
//                } else if contentOffsetY > maximum {
//                    attributes.frame.origin.y = maximum
//                } else {
//                    attributes.frame.origin.y = contentOffsetY
//                }
                
                if contentOffsetY > 0 {
                    return
                }
                
                attributes.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)

            }
        })
        
        return layoutAttributes

    }
    
}
