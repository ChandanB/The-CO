//
//  ChangeNumberVerificationController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import UIKit

class ChangeNumberVerificationController: EnterVerificationCodeController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setRightBarButton(with: "Confirm")
  }

  override func rightBarButtonDidTap() {
    super.rightBarButtonDidTap()
    changeNumber()
  }
}
