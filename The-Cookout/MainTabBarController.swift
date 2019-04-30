//
//  MainTabBarController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import LBTAComponents
import Kingfisher
import Firebase
import Spring

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var user: User?
    let homeController = HomeController()
    let userSearchController = UserSearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        } else {
            API.database.fetchCurrentUser { (user) in
                self.user = user
                self.setupViewControllers()
            }
        }
    }

    func setupViewControllers() {
        
       //home
       //  let homeLayout = UICollectionViewFlowLayout()
        homeController.user = self.user
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: homeController)
        
        //search
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: userSearchController)
        
        //post
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        let likeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        
        // user profile
        let layout = StretchyHeaderLayout()
            
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        userProfileController.user = self.user
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        
        userProfileNavController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavController,
                           userProfileNavController]
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        tabBar.backgroundColor = .white
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let postController = PostController(collectionViewLayout: layout)
            postController.user = self.user
            let navController = UINavigationController(rootViewController: postController)
            
            present(navController, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
        
    var shadow: CAShapeLayer?
    
    override func viewWillLayoutSubviews() {
        self.shadow = tabBar.dropShadow(shadowColor: .black, fillColor: .clear, opacity: 0.075, offset: CGSize(width: 0, height: 1), radius: 15)
        guard let shadow = self.shadow else {return}
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.tabBar.frame.width / 1.025, height: self.tabBar.frame.height), cornerRadius: self.tabBar.frame.width / 1.025)
        let mask = CAShapeLayer()
        var tabFrame = self.tabBar.frame
        
        tabFrame.origin.x = 4.5
        tabFrame.origin.y = 608
        self.tabBar.frame = tabFrame
        self.tabBar.isTranslucent = true
        self.tabBar.barStyle = .default
        
        mask.path = path.cgPath
        tabBar.layer.mask = mask
        
        shadow.path = path.cgPath
        shadow.frame = self.tabBar.frame
        self.shadow = shadow
        tabBar.superview?.layer.insertSublayer(self.shadow!, below: tabBar.layer)
    }
    
    private func addShape(_ tabBar: UITabBar) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPathCircle(tabBar)
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
   
        tabBar.layer.insertSublayer(shapeLayer, at: 0)
        
        return shapeLayer
    }
    
    func createPath(_ tabBar: UITabBar) -> CGPath {
        let height: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = tabBar.frame.width / 2
        
        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough
        // first curve down
        path.addCurve(to: CGPoint(x: centerWidth, y: height),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
        // second curve up
        path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))
        
        // complete the rect
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height))
        path.close()
        
        return path.cgPath
    }
    
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonRadius: CGFloat = 35
        return abs(tabBar.center.x - point.x) > buttonRadius || abs(point.y) > buttonRadius
    }
    
    func createPathCircle(_ tabBar: UITabBar) -> CGPath {
        let radius: CGFloat = 37.0
        let path = UIBezierPath()
        let centerWidth = tabBar.frame.width / 2
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: (centerWidth - radius * 2), y: 0))
        path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: 0))
        path.addLine(to: CGPoint(x: tabBar.frame.width, y: tabBar.frame.height))
        path.addLine(to: CGPoint(x: 0, y: tabBar.frame.height))
        path.close()
        return path.cgPath
    }
    
    
    
    
}

