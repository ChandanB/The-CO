//
//  StickyLayout.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/17/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

class StickyLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.sectionFootersPinToVisibleBounds = true
        self.sectionHeadersPinToVisibleBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sectionFootersPinToVisibleBounds = true
        self.sectionHeadersPinToVisibleBounds = true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        for attribute in attributes {
            adjustAttributesIfNeeded(attribute)
        }
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        adjustAttributesIfNeeded(attributes)
        return attributes
    }
    
    func adjustAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        switch attributes.representedElementKind {
        case UICollectionElementKindSectionHeader?:
            adjustHeaderAttributesIfNeeded(attributes)
        case UICollectionElementKindSectionFooter?:
            adjustFooterAttributesIfNeeded(attributes)
        default:
            break
        }
    }
    
    private func adjustHeaderAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        guard attributes.indexPath.section == 0 else { return }
        
        if collectionView.contentOffset.y < 0 {
            attributes.frame.origin.y = collectionView.contentOffset.y
        }
    }
    
    private func adjustFooterAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        guard attributes.indexPath.section == collectionView.numberOfSections - 1 else { return }
        
        if collectionView.contentOffset.y + collectionView.bounds.size.height > collectionView.contentSize.height {
            attributes.frame.origin.y = collectionView.contentOffset.y + collectionView.bounds.size.height - attributes.frame.size.height
        }
    }
    
}
