//
//  VideoPlayerViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/28/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import LBTAComponents
import SnapKit
import BMPlayer
import NVActivityIndicatorView

class VideoPlayerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var player = BMPlayer()
    var url: URL?
    
    let disabledLabel: UILabel = {
        let label = UILabel()
        label.text = "Comments Disabled On Private Videos"
        label.textColor = .black
        return label
    }()
    
    let privateVideo = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BMPlayerConf.topBarShowInCase = .always
        BMPlayerConf.loaderType  = NVActivityIndicatorType.ballRotateChase
        BMPlayerConf.enableVolumeGestures = false
        BMPlayerConf.enableBrightnessGestures = false
        BMPlayerConf.enablePlaytimeGestures = true
        
        view.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        view.addSubview(player)
//        player.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 320, heightConstant: 240)
        
        player.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.right.equalTo(self.view)
            make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
        
        // Back button event
        player.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen == true { return }
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        let asset = BMPlayerResource(url: self.url!, name: "")
        player.setVideo(resource: asset)
        player.play()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        navigationController?.isNavigationBarHidden = true
    }
    
}
