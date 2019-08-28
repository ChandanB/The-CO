//
//  SelectGroupMembersController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

class SelectGroupMembersController: SelectParticipantsViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    setupRightBarButton(with: "Next")
    setupNavigationItemTitle(title: "New group")
  }

  override func rightBarButtonTapped() {
    super.rightBarButtonTapped()

    createGroup()
  }
}
