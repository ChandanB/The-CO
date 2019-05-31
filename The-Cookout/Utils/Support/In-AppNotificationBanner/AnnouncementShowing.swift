//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//


import UIKit

public func show(shout announcement: Announcement, to: UIViewController, completion: (() -> Void)? = nil) {
  shoutView.craft(announcement, to: to, completion: completion)
}
