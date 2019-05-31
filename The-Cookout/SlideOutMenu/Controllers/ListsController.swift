//
//  ListsController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit
import Firebase

class ListsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().logout(onSuccess: {
            print("Logged out")
        }) { (error) in
            print(error as Any)
        }
        
        navigationItem.title = "Lists"
        navigationController?.navigationBar.prefersLargeTitles = true

        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Lists"
        label.font = UIFont.boldSystemFont(ofSize: 64)
        label.frame = view.frame
        label.textAlignment = .center
        
        view.addSubview(label)
    }

}
