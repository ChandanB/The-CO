//
//  MainSwipeController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/4/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import EZSwipeController
import Firebase

extension NSNotification.Name {
    static let scrollToMessages = NSNotification.Name(Bundle.main.bundleIdentifier! + ".scrollToMessages")
}

class MainSwipeController: UIViewController, UIScrollViewDelegate {

    var currentVC: UIViewController?

    var user: User?
    var screenSize: CGRect?

    var directionLockDisabled: Bool!
    var horizontalViews = [UIViewController]()
    var veritcalViews = [UIViewController]()

    var initialContentOffset = CGPoint() 
    var middleVertScrollVc: VerticalScrollViewController!
    var scrollView: UIScrollView!
    var delegate: MainSwipeControllerDelegate?

    override func viewDidLoad() {
         super.viewDidLoad()
        self.screenSize = UIScreen.main.bounds

        if CURRENT_USER == nil {
            presentLoginController()
        } else {
            Database.database().fetchCurrentUser { (user) in
                self.user = user
                self.middleVc.user = user

                self.setupHorizontalScrollView()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didTapMessages), name: .scrollToMessages, object: nil)
        self.screenSize = UIScreen.main.bounds
    }

    func outerScrollViewShouldScroll() -> Bool {
        if scrollView.contentOffset.x < middleVc.view.frame.origin.x || scrollView.contentOffset.x > 2*middleVc.view.frame.origin.x {
            return false
        } else {
            return true
        }
    }

    @objc func refreshView() {
        print("View refreshed")
        self.view.setNeedsDisplay()
    }

    func setupHorizontalScrollView() {

        //Setup Vertical Scroll View
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc: middleVc, topVc: topVc, bottomVc: bottomVc)
        delegate = middleVertScrollVc

        //Setup Horizontal Scroll View
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false

        let view = (x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: self.view.bounds.height)

        scrollView.frame = CGRect(x: view.x, y: view.y, width: view.width, height: view.height)

        self.view.addSubview(scrollView)

        let scrollWidth  = 3 * view.width
        let scrollHeight  = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)

        leftVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)

        middleVertScrollVc.view.frame = CGRect(x: view.width, y: 0, width: view.width, height: view.height)

        rightVc.view.frame = CGRect(x: 2 * view.width,
                                    y: 0,
                                    width: view.width,
                                    height: view.height
        )

        addChild(leftVc)
        addChild(middleVertScrollVc)
        addChild(rightVc)

        scrollView.addSubview(leftVc.view)
        scrollView.addSubview(middleVertScrollVc.view)
        scrollView.addSubview(rightVc.view)

        leftVc.didMove(toParent: self)
        middleVertScrollVc.didMove(toParent: self)
        rightVc.didMove(toParent: self)

        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self
    }

    var topVc = UIViewController()
    var bottomVc = UIViewController()

    var middleVc = MainTabBarController()
    var leftVc = UserSearchController()
    var rightVc = GeneralTabBarController()

    class func containerViewWith(_ leftVC: UIViewController, middleVC: UIViewController, rightVC: UIViewController, topVC: UIViewController?=nil,
                                 bottomVC: UIViewController?=nil, directionLockDisabled: Bool?=false) -> MainSwipeController {
        let container = MainSwipeController()

        container.directionLockDisabled = directionLockDisabled

        container.middleVc = middleVC as! MainTabBarController
        container.leftVc = leftVC as! UserSearchController
        container.rightVc = rightVC as! GeneralTabBarController

        return container
    }

    @objc func didTapMessages() {
      scrollToPage(page: 2, animated: true)
    }

    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }

    private func presentLoginController() {
        DispatchQueue.main.async {
            let loginController = LoginController(alignment: .center)
            let navController = UINavigationController(rootViewController: loginController)
            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension MainSwipeController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximumHorizontalOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset = scrollView.contentOffset.x
        let percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset

        directionLockDisabled = true

        if percentageHorizontalOffset >= 0.45 && percentageHorizontalOffset < 6.0 {
            UIView.animate(withDuration: 0.2, animations: {
            })
        }

        if percentageHorizontalOffset == 0.5 {
            UIView.animate(withDuration: 0.2, animations: {
            })
        }

        if percentageHorizontalOffset < 0.5 {
            UIView.animate(withDuration: 0.2, animations: {
            })
        }

        if percentageHorizontalOffset > 0.666667 {
            UIView.animate(withDuration: 0.05, animations: {
            })
        }

        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
            self.scrollView!.setContentOffset(newOffset, animated: false)
        }
    }

}
