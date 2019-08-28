//
//  PreviewPhotoContainerView.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/17/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Photos

class PreviewPhotoContainerView: UIView {

    var delegate: ReturnPostImageDelegate?

    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "circular-arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()

    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return button
    }()

    private let savedLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Successfully"
        label.clipsToBounds = true
        label.layer.cornerRadius = 4
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.alpha = 0.7
        label.numberOfLines = 0
        label.backgroundColor = .black
        label.textAlignment = .center
        return label
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "share").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()

    @objc func handleSave() {
        guard let previewImage = previewImageView.image else { return }

        let library = PHPhotoLibrary.shared()

        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (_, err) in
            if let err = err {
                print("Failed to save image to photo library:", err)
                return
            }
            DispatchQueue.main.async {
                self.presentSavedLabel()
            }
        }

    }

    @objc func handleNext() {
        guard let image = previewImageView.image else { return }
        self.delegate?.returnPostImage(image: image)
        self.removeFromSuperview()
    }

    @objc func handleCancel() {
        self.removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(previewImageView)
        previewImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        addSubview(cancelButton)
        cancelButton.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 24, bottomConstant: 34, rightConstant: 0, widthConstant: 50, heightConstant: 50)

        addSubview(saveButton)
        saveButton.anchor(nil, left: nil, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 24, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        saveButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        addSubview(nextButton)
        nextButton.anchor(nil, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 34, rightConstant: 24, widthConstant: 80, heightConstant: 80)
    }

    private func presentSavedLabel() {
        addSubview(savedLabel)
        savedLabel.alpha = 1
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        savedLabel.center = self.center

        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: { (_) in

            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                self.savedLabel.alpha = 0
            }, completion: { (_) in
                self.savedLabel.removeFromSuperview()
            })

        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
