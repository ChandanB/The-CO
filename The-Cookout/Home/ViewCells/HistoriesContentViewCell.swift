//
//  HistoriesContentViewCell.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/31/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

protocol HistoryDelegate {
    func didSelectHistory(history: HistoryTransitionObject)
}

class HistoriesContentViewCell: UICollectionViewCell, ContentViewCell {
    // MARK: - Properties
    var data: HistoriesContent!
    var delegate: HistoryDelegate? = nil
    
    // MARK: - UI Elements
    fileprivate var collectionView: UICollectionView!
    
    // MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCollectionView()
        
        addSubview(collectionView)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    fileprivate func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(HistoryViewCell.self, forCellWithReuseIdentifier: HistoriesContentViewCell.identifier())
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    fileprivate func setupConstraints() {
        collectionView.fillSuperview()
    }
    
    // MARK: - ContentViewCellProtocol
    public class func identifier() -> String {
        return "kHistoriesContentViewCell"
    }
}

// MARK: - Extensions
extension HistoriesContentViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.histories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewCell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoriesContentViewCell.identifier(), for: indexPath) as! HistoryViewCell
        
        viewCell.content = data.histories[indexPath.row]
        
        return viewCell
    }
}

extension HistoriesContentViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let history = data?.histories[indexPath.row] else { return }
        
        let center = collectionView.convert(collectionView.cellForItem(at: indexPath)!.center, to: UIApplication.shared.keyWindow!.rootViewController!.view)
        
        delegate?.didSelectHistory(history: HistoryTransitionObject(history: history, position: center))
    }
}

