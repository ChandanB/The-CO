//
//  AddGroupMembersController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//
import UIKit

class AddGroupMembersController: SelectParticipantsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setupRightBarButton(with: "Add")
    setupNavigationItemTitle(title: "Add users")
  }

  override func rightBarButtonTapped() {
    super.rightBarButtonTapped()

    addNewMembers()
  }
}
