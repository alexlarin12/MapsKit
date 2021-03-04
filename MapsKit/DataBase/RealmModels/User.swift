//
//  User.swift
//  MapsKit
//
//  Created by Alex Larin on 02.03.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override static func primaryKey() -> String? {
            return "login"
        }
}
