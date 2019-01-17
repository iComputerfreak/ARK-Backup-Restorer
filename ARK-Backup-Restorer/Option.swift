//
//  Option.swift
//  ARK-Backup-Restorer
//
//  Created by Jonas Frey on 12.12.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

class Option: Argument, Hashable {
    let shortName: String
    let longName: String?
    let hasParameter: Bool
    // TODO: Check for nil in functions
    var parameter: String?
    
    init(shortName: String, longName: String, hasParameter: Bool, description: String) {
        self.shortName = shortName
        self.longName = longName
        self.hasParameter = hasParameter
        super.init(name: longName, description: description)
    }
    
    static func == (lhs: Option, rhs: Option) -> Bool {
        if lhs.shortName != rhs.shortName { return false }
        if lhs.longName != rhs.longName { return false }
        if lhs.hasParameter != rhs.hasParameter { return false }
        if lhs.description != rhs.description { return false }
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.shortName)
        hasher.combine(self.longName)
        hasher.combine(self.hasParameter)
        hasher.combine(self.description)
    }
}
