//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

extension UIView {
  var safeYCoordinate: CGFloat {
    let y: CGFloat
    if #available(iOS 11.0, *) {
      y = safeAreaInsets.top
    } else {
      y = 0
    }

    return y
  }

  var isiPhoneX: Bool {
    return safeYCoordinate > 20
  }
}
