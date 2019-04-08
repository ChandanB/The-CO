////
////  ChatMessageCell.swift
////  The-Cookout
////
////  Created by Chandan Brown on 5/20/18.
////  Copyright © 2018 Chandan B. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//import BMPlayer
//import SnapKit
//import NVActivityIndicatorView
//
//class ChatMessageCell: UITableViewCell {
//    
//    let messageLabel = UILabel()
//    let bubbleBackgroundView = UIView()
//    
//    var cellLeadingConstraint: NSLayoutConstraint!
//    var cellTrailingConstraint: NSLayoutConstraint!
//    
//    var chatMessage: Message! {
//        didSet {
//            bubbleBackgroundView.backgroundColor = chatMessage.isIncoming ?? true ? .white : .darkGray
//            messageLabel.textColor = chatMessage.isIncoming ?? true ? .black : .white
//            
//            messageLabel.text = chatMessage.text
//            
//            if chatMessage.isIncoming ?? true  {
//                cellLeadingConstraint.isActive = true
//                cellTrailingConstraint.isActive = false
//            } else {
//                cellLeadingConstraint.isActive = false
//                cellTrailingConstraint.isActive = true
//            }
//        }
//    }
//    
//    var chatLogController: ChatLogController?
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        backgroundColor = .clear
//        bubbleBackgroundView.backgroundColor = .yellow
//        bubbleBackgroundView.layer.cornerRadius = 12
//        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.numberOfLines = 0
//        
//        addSubview(bubbleBackgroundView)
//        addSubview(messageLabel)
//        
//        addSubview(profileImageView)
//        addSubview(player)
//        
//        bubbleBackgroundView.addSubview(messageImageView)
//        bubbleBackgroundView.addSubview(playButton)
//        bubbleBackgroundView.addSubview(activityIndicatorView)
//        
//        
//        // lets set up some constraints for our label
//        let constraints = [
//            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
//            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
//            
//            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
//            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
//            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
//            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
//            
//            messageImageView.leftAnchor.constraint(equalTo: bubbleBackgroundView.leftAnchor),
//            messageImageView.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor),
//            messageImageView.widthAnchor.constraint(equalTo: bubbleBackgroundView.widthAnchor),
//            messageImageView.heightAnchor.constraint(equalTo: bubbleBackgroundView.heightAnchor),
//            
//            playButton.centerXAnchor.constraint(equalTo: bubbleBackgroundView.centerXAnchor),
//            playButton.centerYAnchor.constraint(equalTo: bubbleBackgroundView.centerYAnchor),
//            playButton.widthAnchor.constraint(equalToConstant: 50),
//            playButton.heightAnchor.constraint(equalToConstant: 50),
//            
//            activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleBackgroundView.centerXAnchor),
//            activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleBackgroundView.centerYAnchor),
//            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
//            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
//            
//            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
//            profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            profileImageView.widthAnchor.constraint(equalToConstant: 32),
//            profileImageView.heightAnchor.constraint(equalToConstant: 32)
//        ]
//        
//        NSLayoutConstraint.activate(constraints)
//        
//        cellLeadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
//        cellLeadingConstraint.isActive = false
//        
//        cellTrailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
//        cellTrailingConstraint.isActive = true
//        
//        
//        
//        
//        
//    }
//    
//    let activityIndicatorView: UIActivityIndicatorView = {
//        let aiv = UIActivityIndicatorView(style: .whiteLarge)
//        aiv.translatesAutoresizingMaskIntoConstraints = false
//        aiv.hidesWhenStopped = true
//        return aiv
//    }()
//    
//    lazy var playButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        let image = UIImage(named: "play")
//        button.tintColor = UIColor.white
//        button.setImage(image, for: UIControl.State())
//        
//        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
//        
//        return button
//    }()
//    
//    var playerLayer: AVPlayerLayer?
//    //    var player: AVPlayer?
//    
//    var player = BMPlayer()
//    var count = 0
//    
//    @objc func handlePlay() {
//        
//        if let videoUrlString = chatMessage?.videoUrl, let url = URL(string: videoUrlString) {
//            count += 1
//            print(count)
//            // (self.controller as? ChatLogController)?.handleShowVideoController(url)
//        }
//        
//        //        player = AVPlayer(url: url)
//        //
//        //        playerLayer = AVPlayerLayer(player: player)
//        //        playerLayer?.frame = bubbleView.bounds
//        //        bubbleView.layer.addSublayer(playerLayer!)
//        //
//        //        player?.play()
//        //        activityIndicatorView.startAnimating()
//        //        playButton.isHidden = true
//    }
//    
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        playerLayer?.removeFromSuperlayer()
//        player.pause()
//        activityIndicatorView.stopAnimating()
//    }
//    
//    static let blueColor = UIColor(r: 0, g: 137, b: 249)
//    
//    let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 16
//        imageView.layer.masksToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
//    
//    lazy var messageImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 16
//        imageView.layer.masksToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
//        
//        return imageView
//    }()
//    
//    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
//        if chatMessage?.videoUrl != "" {
//            return
//        }
//        
//        if let imageView = tapGesture.view as? UIImageView {
//            self.chatLogController?.performZoomInForStartingImageView(imageView)
//        }
//    }
//    
//    var bubbleWidthAnchor: NSLayoutConstraint?
//    var bubbleViewRightAnchor: NSLayoutConstraint?
//    var bubbleViewLeftAnchor: NSLayoutConstraint?
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
