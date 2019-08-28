//
//  LoginController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents
import LBTATools
import Spring
import PKHUD

class LoginController: LBTAFormController {

    let logoContainerView: SpringView = {
        let view = SpringView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "cookout_logo"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(widthConstant: 300, heightConstant: 80)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return view
    }()

    private lazy var emailTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.constrainHeight(60)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()

    private lazy var passwordTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.constrainHeight(60)
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()

    let loginButton: SpringButton = {
        let button = SpringButton(type: .system)
        button.constrainHeight(60)

        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    let forgotPasswordButton: SpringButton = {
        let button = SpringButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(UIColor(r: 17, g: 155, b: 237), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        return button
    }()

    let dontHaveAccountButton: SpringButton = {
        let button = SpringButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(r: 17, g: 154, b: 237)
            ]))

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowRegister), for: .touchUpInside)
        return button
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0

        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = twitterBlue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        }
    }

    @objc func handleLogin() {
        HUD.show(.progress)
        HUD.dimsBackground = true

        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }

        Auth.auth().signIn(withEmail: email, password: password) { (_, err) in
            if let error = err {
                print("Failed to Sign In:", error)
                self.loginButton.animation = "pop"
                self.loginButton.curve = "spring"
                self.loginButton.duration = 1.2
                self.loginButton.animate()
                HUD.hide()
                return
            }

            HUD.hide()
            self.handleAnimations()
        }
    }

    @objc func handleShowRegister() {
        let registerController = RegisterController(alignment: .center)
        navigationController?.pushViewController(registerController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white

        view.addSubview(logoContainerView)
        logoContainerView.anchor(bottom: formContainerStackView.topAnchor, heightConstant: 200)
        logoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        setupInputFields()
    }

    func setupInputFields() {
        formContainerStackView.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        formContainerStackView.axis = .vertical
        formContainerStackView.spacing = 12

        formContainerStackView.addArrangedSubview(emailTextField)
        formContainerStackView.addArrangedSubview(passwordTextField)

        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchor(formContainerStackView.bottomAnchor, right: formContainerStackView.rightAnchor, topConstant: 12, rightConstant: 36, heightConstant: 12)

        view.addSubview(loginButton)
        loginButton.anchor(forgotPasswordButton.bottomAnchor, left: formContainerStackView.leftAnchor, right: formContainerStackView.rightAnchor, topConstant: 12, leftConstant: 24, rightConstant: 24, heightConstant: 60)

        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 24, rightConstant: 0, widthConstant: 0, heightConstant: 60)

    }

    fileprivate func handleAnimations() {
        self.dontHaveAccountButton.animation = "fall"
        self.dontHaveAccountButton.duration = 0.1
        self.dontHaveAccountButton.animate()

        self.emailTextField.animation = "zoomOut"
        self.emailTextField.curve = "easeOut"
        self.emailTextField.duration = 0.2
        self.emailTextField.animate()
        self.emailTextField.animateNext {
            self.passwordTextField.animation = "zoomOut"
            self.passwordTextField.curve = "easeOut"
            self.passwordTextField.duration = 0.2
            self.passwordTextField.animate()
            self.passwordTextField.animateNext {
                self.forgotPasswordButton.animation = "zoomOut"
                self.passwordTextField.duration = 0.2
                self.forgotPasswordButton.animate()
                self.forgotPasswordButton.animateNext {
                    self.loginButton.animation = "zoomOut"
                    self.loginButton.curve = "easeOut"
                    self.loginButton.duration = 0.2
                    self.loginButton.animate()
                    self.loginButton.animateNext {
                        self.logoContainerView.animation = "pop"
                        self.logoContainerView.curve = "easeOut"
                        self.logoContainerView.duration = 1.0
                        self.logoContainerView.rotate = 3.0
                        self.logoContainerView.animate()
                        self.logoContainerView.animateNext {
                            self.logoContainerView.animation = "fall"
                            self.logoContainerView.curve = "easeIn"
                            self.logoContainerView.duration = 1.0
                            self.logoContainerView.animate()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 30
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 30
            }
        }
    }

    @objc private func handleTapOnView() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}

extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
