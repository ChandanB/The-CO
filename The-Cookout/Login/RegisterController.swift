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

class RegisterController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        DispatchQueue.main.async {
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
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
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
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
    
    @objc func handleSignUp() {
        dismissKeyboard()
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user , error) in
            
            if let err = error {
                print("Failed to create user:", err)
                self.signUpButton.animation = "shake"
                self.signUpButton.animate()
                return
            }
            
            print("Successfully created user:", user?.user.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(filename).jpg")
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if let err = error {
                    print("Failed to upload profile image:", err)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    
                    if let err = error {
                        print("Failed to get profile url:", err)
                        return
                    }
                    
                    guard let downloadUrl = url else { return }
                    let profileImageUrl = downloadUrl.absoluteString
                    
                    print("Successfully uploaded profile image:", profileImageUrl)
                    
                    
                    guard let uid = user?.user.uid else { return }
                    
                    let dictionaryValues = ["name": name, "email": email, "username": username, "bio": "New Account 🤐", "profileImageUrl": profileImageUrl]
                    let values = [uid: dictionaryValues]
                    
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if let err = err {
                            print("Failed to save user info into db:", err)
                            return
                        }
                        
                        print("Successfully saved user info to db")
                        
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                        mainTabBarController.setupViewControllers()
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        })
    }
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let fontStyle = UIFont.systemFont(ofSize: 14)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font: fontStyle, NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Log In.", attributes: [NSAttributedStringKey.foregroundColor: UIColor(r: 17, g: 155, b: 237),  NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    
    @objc func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        self.hideKeyboardWhenTapped()
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 140, heightConstant: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
    }
    
    func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [nameTextField, usernameTextField, emailTextField, passwordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 18, bottomConstant: 0, rightConstant: 18, widthConstant: 0, heightConstant: 280)
    }
    
    @objc func handleTextInputChange() {
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if checkIfFormIsValid(name, email: email, username: username, password: password) == true {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor(r: 17, g: 155, b: 237)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(r: 149, g: 204, b: 244)
        }
        
    }
    
    func checkIfFormIsValid(_ name: String, email: String, username: String, password: String) -> Bool {
        
        if isValidPassword(password) != true {
            return false
        }
        
        if isValidUsername(username) != true {
            return false
        }
        
        if email.count > 0  && name.count > 0  && name.count < 30 {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isValidPassword(_ password: String) -> Bool {
        if (password.count < 0 || password.count > 20){
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 70
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 70
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
  
}


