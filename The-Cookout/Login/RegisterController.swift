//
//  LoginController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/13/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import Firebase
import LBTAComponents
import Spring
import PKHUD

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

class RegisterController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var addPhotoButton: SpringButton = {
        let button = SpringButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        return button
    }()
    
    let usernameTextField: SpringTextField = {
        let tf = SpringTextField()
        let leftLabel = UILabel(frame: CGRect(x: 4, y: 0, width: 20, height: 20))
        leftLabel.text = " @"
        leftLabel.textColor = .black
        
        tf.leftView = leftLabel
        tf.leftViewMode = .always
        
        tf.placeholder = "Username"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let nameTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.placeholder = "Name"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let emailTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: SpringTextField = {
        let tf = SpringTextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: SpringButton = {
        let button = SpringButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let fontStyle = UIFont.systemFont(ofSize: 14)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: fontStyle, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log In.", attributes: [NSAttributedString.Key.foregroundColor: UIColor(r: 17, g: 155, b: 237),  NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = .white
        
        view.addSubview(addPhotoButton)
        
        addPhotoButton.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 140, heightConstant: 140)
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
    }
    
    @objc func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func openImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            addPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            addPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width/2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, usernameTextField, emailTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(addPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 18, bottomConstant: 0, rightConstant: 18, widthConstant: 0, heightConstant: 280)
    }
    
    private func resetInputFields() {
        nameTextField.text = ""
        emailTextField.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        emailTextField.isUserInteractionEnabled = true
        usernameTextField.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
    }
    
    @objc func handleTextInputChange() {
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if checkIfFormIsValid(name, email: email, username: username, password: password) == true {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = twitterBlue
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        }
        
    }
    
    func checkIfFormIsValid(_ name: String, email: String, username: String, password: String) -> Bool {
        
        if !isValidName(name) || email.count < 0 {
            return false
        }
        
        if !isValidUsername(username) && username.count > 0 {
            usernameTextField.layer.borderColor = UIColor.red.cgColor
            usernameTextField.layer.borderWidth = 1
            usernameTextField.layer.cornerRadius = 4
            return false
        } else {
            usernameTextField.layer.borderWidth = 0
        }
        
        if !isValidPassword(password) {
            if password.count > 0 {
                passwordTextField.layer.borderColor = UIColor.red.cgColor
                passwordTextField.layer.borderWidth = 1
                passwordTextField.layer.cornerRadius = 4
            }
            return false
        } else {
            passwordTextField.layer.borderColor = UIColor.green.cgColor
        }
        
        return true
        
    }
    
    fileprivate func isValidName(_ name: String) -> Bool {
        if (name.count <= 0 || name.count > 30){
            return false
        } else {
            return true
        }
    }
    
    fileprivate func isValidPassword(_ password: String) -> Bool {
        if (password.count < 6 || password.count > 20){
            
            return false
        }
        
        let uppercase = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
        let uppercaseLetters = password.components(separatedBy: uppercase)
        let uppercaseCharacters: String = uppercaseLetters.joined()
        
        let lowercase = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz").inverted
        let lowercaseLetters = password.components(separatedBy: lowercase)
        let lowercaseCharacters: String = lowercaseLetters.joined()
        
        let numbers = CharacterSet(charactersIn: "0123456789").inverted
        let digits = password.components(separatedBy: numbers)
        let num: String = digits.joined()
        
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options:  NSRegularExpression.Options())
        
        if regex.firstMatch(in: password, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, password.length)) != nil {
            return (uppercaseCharacters.count >= 1 && lowercaseCharacters.count >= 1)
        } else {
            return (uppercaseCharacters.count >= 1 && lowercaseCharacters.count >= 1 && num.count >= 1)
        }
        
    }
    
    fileprivate func isValidUsername(_ username: String) -> Bool {
        
        if (username.count < 0 || username.count > 18){
            return false
        }
        
        let characters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_").inverted
        let letters = username.components(separatedBy: characters)
        let strCharacters: String = letters.joined()
        
        if username.rangeOfCharacter(from: characters) != nil {
            return false
        } else {
            return (strCharacters.count >= 1)
        }
        
    }
    
    @objc private func handleTapOnView(_ sender: UITextField) {
        nameTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}



// MARK: - Handle Sign Up
extension RegisterController {
    @objc func handleSignUp() {
        let bio = "New Account 🤐"
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let image = self.addPhotoButton.imageView?.image else { return }
        
        nameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        usernameTextField.isUserInteractionEnabled = false
        passwordTextField.isUserInteractionEnabled = false
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        
        dismissKeyboard()
        
        HUD.show(.progress)
        HUD.dimsBackground = true
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += 70
        }
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += 70
        }
        
        Auth.auth().signUp(bio: bio, name: name, username: username, email: email, password: password, image: image) { (err) in
            if err != nil {
                self.signUpButton.animation = "pop"
                self.signUpButton.curve = "spring"
                self.signUpButton.duration = 1.2
                self.signUpButton.animate()
                HUD.hide()
                return
            }
            
                        
            HUD.hide()
            self.handleAnimations()
        }
    }
    
    fileprivate func handleAnimations() {
        addPhotoButton.animation = "zoomOut"
        addPhotoButton.curve = "easeOut"
        addPhotoButton.duration = 0.2
        addPhotoButton.animate()
        addPhotoButton.animateNext {
            self.nameTextField.animation = "zoomOut"
            self.nameTextField.curve = "easeOut"
            self.nameTextField.duration = 0.2
            self.nameTextField.animate()
            self.nameTextField.animateNext {
                self.usernameTextField.animation = "zoomOut"
                self.usernameTextField.curve = "easeOut"
                self.usernameTextField.duration = 0.2
                self.usernameTextField.animate()
                self.usernameTextField.animateNext {
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
                            self.signUpButton.animation = "flash"
                            self.signUpButton.curve = "easeIn"
                            self.signUpButton.duration = 0.8
                            self.signUpButton.animate()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}


extension RegisterController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 70
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 70
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
