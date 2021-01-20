//
//  EnterVerificationCodeController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit
import Firebase
import ARSLineProgress

class EnterVerificationCodeController: UIViewController {

  let enterVerificationContainerView = EnterVerificationContainerView()
 // var phoneNumberControllerType: PhoneNumberControllerType = .authentication

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = ThemeManager.currentTheme().generalBackgroundColor
    view.addSubview(enterVerificationContainerView)
    enterVerificationContainerView.frame = view.bounds
    enterVerificationContainerView.resend.addTarget(self, action: #selector(sendSMSConfirmation), for: .touchUpInside)
    enterVerificationContainerView.enterVerificationCodeController = self
    configureNavigationBar()
  }

  fileprivate func configureNavigationBar () {
    self.navigationItem.hidesBackButton = true
  }

  func setRightBarButton(with title: String) {
    let rightBarButton = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(rightBarButtonDidTap))
    self.navigationItem.rightBarButtonItem = rightBarButton

  }

  @objc fileprivate func sendSMSConfirmation () {

    if currentReachabilityStatus == .notReachable {
      basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
      return
    }

    enterVerificationContainerView.resend.isEnabled = false
    print("tappped sms confirmation")

    let phoneNumberForVerification = enterVerificationContainerView.titleNumber.text!

    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberForVerification, uiDelegate: nil) { (verificationID, error) in
      if let error = error {
        basicErrorAlertWith(title: "Error", message: error.localizedDescription + "\nPlease try again later.", controller: self)
        return
      }

      print("verification sent")
      self.enterVerificationContainerView.resend.isEnabled = false

      userDefaults.updateObject(for: userDefaults.authVerificationID, with: verificationID)
      self.enterVerificationContainerView.runTimer()
    }
  }

  @objc func rightBarButtonDidTap () {}

  func changeNumber () {
    enterVerificationContainerView.verificationCode.resignFirstResponder()

    let verificationID = userDefaults.currentStringObjectState(for: userDefaults.changeNumberAuthVerificationID)
    let verificationCode = enterVerificationContainerView.verificationCode.text

    if verificationID == nil {
      self.enterVerificationContainerView.verificationCode.shake()
      return
    }

    if currentReachabilityStatus == .notReachable {
      basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
      return
    }

    ARSLineProgress.ars_showOnView(self.view)

    let credential = PhoneAuthProvider.provider().credential (withVerificationID: verificationID!, verificationCode: verificationCode!)

    CURRENT_USER?.updatePhoneNumber(credential, completion: { (error) in
      if error != nil {
        ARSLineProgress.hide()
        basicErrorAlertWith(title: "Error", message: error?.localizedDescription ?? "Number changing process failed. Please try again later.", controller: self)
        return
      }

      let userReference = USERS_REF.child(CURRENT_USER!.uid)
      userReference.updateChildValues(["phoneNumber": self.enterVerificationContainerView.titleNumber.text! ]) { (error, _) in
        if error != nil {
          ARSLineProgress.hide()
          basicErrorAlertWith(title: "Error", message: error?.localizedDescription ?? "Number changing process failed. Please try again later.", controller: self)
          return
        }

        ARSLineProgress.showSuccess()
        self.dismiss(animated: true) {
          AppUtility.lockOrientation(.allButUpsideDown)
        }
      }
    })
  }

  func authenticate() {
    print("tapped")
    enterVerificationContainerView.verificationCode.resignFirstResponder()
    if currentReachabilityStatus == .notReachable {
      basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
      return
    }

    let verificationID = userDefaults.currentStringObjectState(for: userDefaults.authVerificationID)
    let verificationCode = enterVerificationContainerView.verificationCode.text

    guard let unwrappedVerificationID = verificationID, let unwrappedVerificationCode = verificationCode else {
      ARSLineProgress.showFail()
      self.enterVerificationContainerView.verificationCode.shake()
      return
    }

    if currentReachabilityStatus == .notReachable {
      basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
    }

    ARSLineProgress.ars_showOnView(self.view)

    let credential = PhoneAuthProvider.provider().credential (
      withVerificationID: unwrappedVerificationID,
      verificationCode: unwrappedVerificationCode)

    Auth.auth().signInAndRetrieveData(with: credential) { (_, error) in
      if error != nil {
        ARSLineProgress.hide()
        basicErrorAlertWith(title: "Error", message: error?.localizedDescription ?? "Oops! Something happened, try again later.", controller: self)
        return
      }
      let destination = UserMessageProfileController()
      AppUtility.lockOrientation(.portrait)
      destination.userProfileContainerView.username.text = self.enterVerificationContainerView.titleNumber.text
      destination.checkIfUserDataExists(completionHandler: { (isCompleted) in
        guard isCompleted else {ARSLineProgress.showFail(); return }
        ARSLineProgress.hide()
        guard self.navigationController != nil else { return }
        if !(self.navigationController!.topViewController!.isKind(of: UserMessageProfileController.self)) {
          self.navigationController?.pushViewController(destination, animated: true)
        }
      })
    }
  }
}
