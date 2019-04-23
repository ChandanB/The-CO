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

        layoutAttributes.forEach({ (attributes) in
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader && attributes.indexPath.section == 0 {
                
                guard let collectionView = collectionView else { return }
                
                let contentOffsetY = collectionView.contentOffset.y
                
                let width = collectionView.frame.width
                let height = attributes.frame.height - (contentOffsetY)
                
                let minimum: CGFloat = 0
                let maximum: CGFloat = attributes.frame.height
                
                if contentOffsetY < minimum {
                    attributes.frame = CGRect(x: minimum, y: contentOffsetY, width: width, height: height)
                } else if contentOffsetY > maximum {
                    attributes.frame.origin.y = maximum - 60
                } else if contentOffsetY > 60 {
                    attributes.frame.origin.y = contentOffsetY - 60
                }
                
            }
            
        })
        
        return layoutAttributes

    }
    
}
