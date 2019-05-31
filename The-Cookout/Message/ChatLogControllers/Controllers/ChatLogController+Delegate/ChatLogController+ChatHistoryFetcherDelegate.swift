//
//  ChatLogController+ChatHistoryFetcherDelegate.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

extension ChatLogController: ChatLogHistoryDelegate {
  
  func chatLogHistory(isEmpty: Bool) {
    refreshControl.endRefreshing()
  }
  
  func chatLogHistory(updated messages: [Message], at indexPaths: [IndexPath]) {
    contentSizeWhenInsertingToTop = collectionView?.contentSize
    isInsertingCellsToTop = true
    refreshControl.endRefreshing()
    
    self.messages = messages
    
    UIView.performWithoutAnimation {
      collectionView?.performBatchUpdates ({
        collectionView?.insertItems(at: indexPaths)
      }, completion: nil)
    }
  }
}
