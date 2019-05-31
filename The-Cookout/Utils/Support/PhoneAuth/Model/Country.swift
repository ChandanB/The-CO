//
//  Country.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//


import Foundation

class Country: NSObject {
  
  var countries = [[String: String]]()
  
  override init() {
    super.init()
    
    fetchCountries()
  }
  
  func fetchCountries () {
    let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")!
    let url = URL(fileURLWithPath: path)
    guard let data = try? Data(contentsOf: url) else { return }
    guard let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) else {
      return
    }
    guard let dictionary = plist as? [[String: String]] else { return }
    countries = dictionary
  }
}
