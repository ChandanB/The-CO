//
//  LoginController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/14/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents
import Spring
import PKHUD

class LoginController: UIViewController {
    
    let logoContainerView: SpringView = {
        let view = SpringView()
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "cookout_logo"))
        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        logoImageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 300, heightConstant: 80)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    let emailTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
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
    
    let loginButton: SpringButton = {
        let button = SpringButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleLogin() {
        HUD.show(.progress)
        HUD.dimsBackground = true
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let err = error {
                print("Failed to Sign In:", err)
                self.loginButton.animation = "pop"
                self.loginButton.curve = "spring"
                self.loginButton.duration = 1.2
                self.loginButton.animate()
                HUD.hide()
                return
            }
            //successfully logged in our user
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? BaseSlidingController else { return }
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot.value ?? "")
                
              //  mainTabBarController.setupViewControllers()
                HUD.hide()
                self.handleAnimations()
                
            }) { (err) in
                print("Failed to fetch user:", err)
            }
        })
    }
    
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
    
    @objc func handleShowRegister() {
        let registerController = RegisterController()
        navigationController?.pushViewController(registerController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTapped()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        setupInputFields()
    }
    
    func setupInputFields() {
        
        let topStackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        
        topStackView.distribution = .fillEqually
        topStackView.axis = .vertical
        topStackView.spacing = 10
        
        view.addSubview(topStackView)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loginButton)
        
        topStackView.anchor(logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 18, bottomConstant: 10, rightConstant: 18, widthConstant: 0, heightConstant: 110)
        
        forgotPasswordButton.anchor(topStackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 260, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 10)
        
        loginButton.anchor(forgotPasswordButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 18, bottomConstant: 0, rightConstant: 18, widthConstant: 0, heightConstant: 50)
        
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


