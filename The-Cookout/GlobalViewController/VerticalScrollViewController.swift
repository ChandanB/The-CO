//
//  VerticalScrollViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/4/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class VerticalScrollViewController: UIViewController, MainSwipeControllerDelegate {
    
    var middleVc = MainTabBarController()
    var scrollView: UIScrollView!
    
    class func verticalScrollVcWith(middleVc: UIViewController,
                                    topVc: UIViewController?=nil,
                                    bottomVc: UIViewController?=nil) -> VerticalScrollViewController {
        let middleScrollVc = VerticalScrollViewController()
        
        middleScrollVc.middleVc = middleVc as! MainTabBarController
        
        return middleScrollVc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        scrollView.frame = CGRect(x: view.x, y: view.y, width: view.width, height: view.height)
        self.view.addSubview(scrollView)
        
        let scrollWidth: CGFloat  = view.width
        var scrollHeight: CGFloat
        
        scrollHeight  = view.height
        middleVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        
        addChild(middleVc)
        scrollView.addSubview(middleVc.view)
        middleVc.didMove(toParent: self)
        
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
    }
    
    // MARK: - SnapContainerViewControllerDelegate Methods
    
    func outerScrollViewShouldScroll() -> Bool {
        if scrollView.contentOffset.y < middleVc.view.frame.origin.y || scrollView.contentOffset.y > 2*middleVc.view.frame.origin.y {
            return false
        } else {
            return true
        }
    }
    
}

