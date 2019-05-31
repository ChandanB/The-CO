//
//  ChatInputContainerView.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//



import UIKit
import AVFoundation


public func getInputTextViewMaxHeight() -> CGFloat? {
  if UIDevice.current.orientation.isLandscape {
    if DeviceType.iPhone5orSE {
      return InputContainerViewConstants.maxContainerViewHeightLandscape4Inch
    } else if DeviceType.iPhone678 {
      return InputContainerViewConstants.maxContainerViewHeightLandscape47Inch
    } else if DeviceType.iPhone678p || DeviceType.iPhoneX {
      return InputContainerViewConstants.maxContainerViewHeightLandscape5558inch
    } else {
      return InputContainerViewConstants.maxContainerViewHeightLandscape4Inch
    }
  } else {
    return InputContainerViewConstants.maxContainerViewHeight
  }
}

struct InputContainerViewConstants {
  static let maxContainerViewHeight: CGFloat = 220.0
  static let maxContainerViewHeightLandscape4Inch: CGFloat = 88.0
  static let maxContainerViewHeightLandscape47Inch: CGFloat = 125.0
  static let maxContainerViewHeightLandscape5558inch: CGFloat = 125.0
  static let containerInsetsWithAttachedImages = UIEdgeInsets(top: 175, left: 8, bottom: 8, right: 30)
  static let containerInsetsDefault = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 30)
}


class ChatInputContainerView: UIView {
  var audioPlayer: AVAudioPlayer!
  var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout! = nil
  weak var trayDelegate: ImagePickerTrayControllerDelegate?
  var selectedMedia = [MediaObject]()
  weak var mediaPickerController: MediaPickerControllerNew?
  var maxTextViewHeight: CGFloat = 0.0
  
  weak var chatLogController: ChatLogController? {
    didSet {
      sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
      attachButton.addTarget(chatLogController, action: #selector(ChatLogController.togglePhoto), for: .touchDown)
      recordVoiceButton.addTarget(chatLogController, action: #selector(ChatLogController.toggleVoiceRecording), for: .touchDown)
    }
  }
  
  override var intrinsicContentSize: CGSize {
    get {
      let textSize = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
    let maxTextViewHeightRelativeToOrientation: CGFloat! = getInputTextViewMaxHeight()
      
      if textSize.height >= maxTextViewHeightRelativeToOrientation {
        maxTextViewHeight = maxTextViewHeightRelativeToOrientation
        inputTextView.isScrollEnabled = true
      } else {
        inputTextView.isScrollEnabled = false
        maxTextViewHeight = textSize.height + 12
      }
      return CGSize(width: self.bounds.width, height: maxTextViewHeight )
    }
  }
  
  lazy var inputTextView: UITextView = {
    let textView = UITextView()
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.delegate = self
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.keyboardAppearance = ThemeManager.currentTheme().keyboardAppearance
    textView.isScrollEnabled = false
    textView.layer.cornerRadius = 18
    textView.textColor = ThemeManager.currentTheme().generalTitleColor
    textView.textContainerInset = InputContainerViewConstants.containerInsetsDefault
    textView.backgroundColor = ThemeManager.currentTheme().inputTextViewColor
    textView.indicatorStyle = ThemeManager.currentTheme().scrollBarStyle
    
    return textView
  }()
  
  let placeholderLabel: UILabel = {
    let placeholderLabel = UILabel()
    placeholderLabel.text = "Message"
    placeholderLabel.sizeToFit()
    placeholderLabel.textColor = ThemeManager.currentTheme().generalSubtitleColor
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    
    return placeholderLabel
  }()
  
  let attachButton: UIButton = {
    let attachButton = UIButton()
    attachButton.tintColor = SocialPointPalette.defaultBlue
    attachButton.translatesAutoresizingMaskIntoConstraints = false
    attachButton.setImage(UIImage(named: "ConversationAttach"), for: .normal)
    attachButton.setImage(UIImage(named: "SelectedModernConversationAttach"), for: .selected)
    
    return attachButton
  }()
  
  let recordVoiceButton: UIButton = {
    let recordVoiceButton = UIButton()
    recordVoiceButton.tintColor = SocialPointPalette.defaultBlue
    recordVoiceButton.translatesAutoresizingMaskIntoConstraints = false
    recordVoiceButton.setImage(UIImage(named: "microphone"), for: .normal)
    recordVoiceButton.setImage(UIImage(named: "microphoneSelected"), for: .selected)
    
    return recordVoiceButton
  }()
  
  let sendButton: UIButton = {
    let sendButton = UIButton(type: .custom)
    sendButton.setImage(UIImage(named: "send"), for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.isEnabled = false
    
    return sendButton
  }()
  
  let separator: UIView = {
    let separator = UIView()
    separator.translatesAutoresizingMaskIntoConstraints = false
    separator.backgroundColor = ThemeManager.currentTheme().generalSubtitleColor
    separator.isHidden = false
    
    return separator
  }()
  
  var attachedImages: UICollectionView = {
    var attachedImages = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    return attachedImages
  }()
  
  deinit {
    print("\nCHAT INPUT CONTAINER VIEW DID DEINIT\n")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    print("\nCHAT INPUT CONTAINER VIEW INIT\n")
    if centeredCollectionViewFlowLayout == nil {
      centeredCollectionViewFlowLayout = CenteredCollectionViewFlowLayout()
    }
    
    attachedImages = UICollectionView(centeredCollectionViewFlowLayout: centeredCollectionViewFlowLayout)
    backgroundColor = ThemeManager.currentTheme().barBackgroundColor
		self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
    
    addSubview(attachButton)
    addSubview(recordVoiceButton)
    addSubview(inputTextView)
    addSubview(sendButton)
    addSubview(placeholderLabel)
    inputTextView.addSubview(attachedImages)
    inputTextView.addSubview(separator)
    
    separator.anchor(top: nil, leading: attachedImages.leadingAnchor, bottom: attachedImages.bottomAnchor, trailing: attachedImages.trailingAnchor)
    separator.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
    
    if #available(iOS 11.0, *) {
      attachButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
      inputTextView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
    } else {
      attachButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
      inputTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
    
    attachButton.anchor(bottom: bottomAnchor, width: 35, height: 50)
    
    recordVoiceButton.anchor(left: attachButton.rightAnchor, bottom: bottomAnchor, paddingLeft: 0, width: 35, height: 50)
    
    inputTextView.anchor(top: topAnchor, left: recordVoiceButton.rightAnchor, bottom: bottomAnchor, paddingTop: 6, paddingLeft: 3, paddingBottom: -6)
    
    placeholderLabel.font = UIFont.systemFont(ofSize: (inputTextView.font!.pointSize - 1))
    placeholderLabel.isHidden = !inputTextView.text.isEmpty
    placeholderLabel.anchor(separator.bottomAnchor, left: inputTextView.leftAnchor, bottom: nil, right: inputTextView.rightAnchor, topConstant: inputTextView.font!.pointSize / 2, leftConstant: 12, bottomConstant: 0, heightConstant: 20)
    
    sendButton.anchor(bottom: inputTextView.bottomAnchor, right: inputTextView.rightAnchor, bottomConstant: -4, rightConstant: -4, widthConstant: 30, heightConstant: 30)
    
    configureAttachedImagesCollection()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToWindow() {
    super.didMoveToWindow()
    if #available(iOS 11.0, *) {
      if let window = window {
				self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
      }
    }
  }
}


extension ChatInputContainerView {
  
  func prepareForSend() {
    inputTextView.text = ""
    sendButton.isEnabled = false
    placeholderLabel.isHidden = false
    inputTextView.isScrollEnabled = false
    selectedMedia.removeAll()
    attachedImages.reloadData()
    resetChatInputConntainerViewSettings()
  }
  
  func resetChatInputConntainerViewSettings () {
    
    if selectedMedia.count == 0 {
      
      attachedImages.frame = CGRect(x: 0, y: 0, width: inputTextView.frame.width, height: 0)
      
      self.inputTextView.textContainerInset = InputContainerViewConstants.containerInsetsDefault
      
      separator.isHidden = true
      placeholderLabel.text = "Message"
      
      if inputTextView.text == "" {
        sendButton.isEnabled = false
      }
      
      let textBeforeUpdate = inputTextView.text
      
      inputTextView.text = " "
      inputTextView.invalidateIntrinsicContentSize()
      invalidateIntrinsicContentSize()
      inputTextView.text = textBeforeUpdate
    }
  }
}

extension ChatInputContainerView: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if attachedImages.bounds.contains(touch.location(in: attachedImages)) {
      return false
    }
    return true
  }
}


extension ChatInputContainerView: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    
    chatLogController?.scrollToBottom(at: .top)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    
    placeholderLabel.isHidden = !textView.text.isEmpty
    
    if textView.text == nil || textView.text == "" {
      sendButton.isEnabled = false
    } else {
      sendButton.isEnabled = true
    }
    chatLogController?.isTyping = textView.text != ""
    
    if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
      sendButton.isEnabled = false
    }
    
    invalidateIntrinsicContentSize()
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
      attachButton.isSelected = false
      recordVoiceButton.isSelected = false
   
    if chatLogController?.chatLogAudioPlayer != nil  {
      chatLogController?.chatLogAudioPlayer.stop()
      chatLogController?.chatLogAudioPlayer = nil
    }
    guard chatLogController != nil, chatLogController?.voiceRecordingViewController != nil, chatLogController!.voiceRecordingViewController.recorder != nil else {
      return
    }
    
    if chatLogController!.voiceRecordingViewController.recorder.isRecording {
      chatLogController?.voiceRecordingViewController.stop()
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      if chatLogController!.collectionView!.contentOffset.y >= (chatLogController!.collectionView!.contentSize.height - chatLogController!.collectionView!.frame.size.height - 200) {
        
        if chatLogController?.collectionView?.numberOfSections == 2 {
          chatLogController?.scrollToBottomOfTypingIndicator()
        } else {
          chatLogController?.scrollToBottom(at: .bottom)
        }
      }
    }
    return true
  }
}

