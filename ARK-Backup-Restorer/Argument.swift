//
//  Argument.swift
//  ARK-Backup-Restorer
//
//  Created by Jonas Frey on 14.12.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

class Argument {
    
    let name: String
    let description: String
    var rawArgument: String?
    let matcher: ((String) -> Bool)
    
    init(name: String, description: String, matcher: @escaping ((String) -> Bool) = { _ in return true }) {
        self.name = name
        self.description = description
        self.matcher = matcher
    }
    
    func matches(_ input: String) -> Bool {
        if rawArgument == nil {
            ConsoleIO.logError("Raw value has not been initialized.")
        }
        return matcher(input)
    }
    
}
