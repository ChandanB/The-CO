//
//  SPAPI.swift
//  The-Cookout
//
//  Created by Chandan Brown on 4/29/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import Nora
import Firebase

public enum Users: NRDatabaseTarget {

    case getUser(id: String)
    case createUser(email: String, name: String, username: String)
    case deleteUser(id: String)

    public var baseReference: DatabaseReference {
        return Database.database().reference().child("users")
    }

    public var path: String {

        switch self {
        case .getUser(let id), .deleteUser(let id):
            return id
        case .createUser:
            return uniqueID()
        }
    }

    public var task: NRDatabaseTask {

        switch self {
        case .getUser:
            return .observeOnce(.value)
        case .deleteUser:
            return .removeValue
        case .createUser(let email, let name, let username):
            return .setValue(["email": email, "name": name, "username": username])
        }
    }

}
