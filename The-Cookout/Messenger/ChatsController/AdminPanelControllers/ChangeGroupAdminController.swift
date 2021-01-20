//
//  ChangeGroupAdminController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class ChangeGroupAdminController: SelectNewAdminTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupRightBarButton(with: "Change administrator")
  }

  override func rightBarButtonTapped() {
    super.rightBarButtonTapped()
    setNewAdmin(membersIDs: getMembersIDs())
  }
}
