//
//  Category.swift
//  Todoey
//
//  Created by Matej Korman on 07/05/2018.
//  Copyright © 2018 Matej Korman. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
