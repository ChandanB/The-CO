//
//  LeaveGroupAndChangeAdminController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class LeaveGroupAndChangeAdminController: SelectNewAdminTableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupRightBarButton(with: "Leave the group")
  }

  override func rightBarButtonTapped() {
    super.rightBarButtonTapped()
    leaveTheGroupAndSetAdmin()
  }
}
