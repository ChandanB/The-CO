//
//  RevealableView.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

public enum RevealStyle {
    case slide
    case over
}

public enum RevealSwipeDirection {
    case left
    case right
}

open class RevealableView: UIControl {
    
    @IBInspectable open var width: CGFloat = 0 {
      didSet {
        prepareWidthConstraint()
      }
    }
    
    internal weak var tableView: UICollectionView?
    open internal(set) var reuseIdentifier: String!
    open internal(set) var style: RevealStyle = .slide
    open internal(set) var direction: RevealSwipeDirection = .left
    fileprivate var viewWidthConstraint: NSLayoutConstraint?
    
    /**
     Ensure to call super.didMoveToSuperview in your subclasses!
     */
    open override func didMoveToSuperview() {
      if self.superview != nil {
        prepareWidthConstraint()
      }
      self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal func prepareForReuse() {
      tableView?.prepareRevealableViewForReuse(self)
    }
    
    fileprivate func prepareWidthConstraint() {
      if width > 0 {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
                                            toItem: nil, attribute: .notAnAttribute,
                                            multiplier: 1, constant: width)
        NSLayoutConstraint.activate([constraint])
        viewWidthConstraint = constraint
      } else {
        if let constraint = viewWidthConstraint {
          NSLayoutConstraint.deactivate([constraint])
        }
      }
      setNeedsUpdateConstraints()
    }
}
