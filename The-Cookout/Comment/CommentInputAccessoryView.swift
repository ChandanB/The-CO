//
//  CommentInputAccessoryView.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/20/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents


class CommentInputAccessoryView: UIView, UITextViewDelegate {

    var delegate: CommentInputAccessoryViewDelegate?

    fileprivate let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Comment on post..."
        label.textColor = UIColor.lightGray
        label.backgroundColor = .white
        return label
    }()

    fileprivate let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb
    }()

    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
        submitButton.isEnabled = false
        submitButton.setTitleColor(.lightGray, for: .normal)
    }

    fileprivate let commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.backgroundColor = .white
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        autoresizingMask = .flexibleHeight

        addSubview(submitButton)
        submitButton.anchor(top: safeAreaLayoutGuide.topAnchor, right: rightAnchor, paddingRight: 12, width: 50, height: 50)

        addSubview(commentTextView)
        commentTextView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8)

        setupLineSeparatorView()

        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
    }

    override var intrinsicContentSize: CGSize { return .zero }

    fileprivate func setupLineSeparatorView() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 0.5)
    }

    @objc private func handleTextChange() {
        guard let text = commentTextView.text else { return }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            submitButton.isEnabled = false
            submitButton.setTitleColor(.lightGray, for: .normal)
        } else {
            submitButton.isEnabled = true
            submitButton.setTitleColor(.black, for: .normal)
        }
    }

    @objc func handleSubmit() {
        guard let commentText = commentTextView.text else { return }
        commentTextView.resignFirstResponder()
        delegate?.didSubmit(comment: commentText)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
