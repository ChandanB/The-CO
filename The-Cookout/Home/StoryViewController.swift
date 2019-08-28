//
//  StoryViewController.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {

    var data: HistoryTransitionObject! {
        didSet {
            storyLabel.text = "History from \(data.history.name)"
        }
    }

    // MARK: - UI Elements
    fileprivate let storyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.numberOfLines = 0
        label.withShadow()
        return label
    }()

    fileprivate let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "IconClose").withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.backgroundColor = fbBlueDark
        button.layer.cornerRadius = 20

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = fbBlueLight
        closeButton.addTarget(self, action: #selector(onClose(_:)), for: .touchDown)

        // Add Subviews
        view.addSubview(storyLabel)
        view.addSubview(closeButton)

        // Setup Constrains
        setupConstraints()
    }

    // MARK: - Private
    fileprivate func setupConstraints() {
        // Test
        storyLabel.centerInSuperview()

        // Close Button
        closeButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 10))
        closeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    // MARK: - Handlers
    @objc func onClose(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
