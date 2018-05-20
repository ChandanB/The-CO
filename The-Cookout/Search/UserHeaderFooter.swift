//
//  Cells.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/12/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents


class UserHeader: DatasourceCell {
    
    let textlabel: UILabel = {
       let label = UILabel()
       label.text = "TOP USERS"
       label.font = UIFont.boldSystemFont(ofSize: 16)
       return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .white
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(textlabel)
        textlabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}

class UserFooter: DatasourceCell {
    
    let textlabel: UILabel = {
    let label = UILabel()
    label.text = "SHOW MORE"
    label.textColor = twitterBlue
    label.font = UIFont.systemFont(ofSize: 15)
    return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = .white
        
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        
        addSubview(whiteBackgroundView)
        addSubview(textlabel)
        
        whiteBackgroundView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 14, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        textlabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
