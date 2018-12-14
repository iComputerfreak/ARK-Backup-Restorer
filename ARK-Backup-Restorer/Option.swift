//
//  Option.swift
//  ARK-Backup-Restorer
//
//  Created by Jonas Frey on 12.12.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

struct Option: Hashable {
    
    let shortName: String
    let longName: String?
    let hasParameter: Bool
    let description: String
    
    init(shortName: String, longName: String, hasParameter: Bool, description: String) {
        self.shortName = shortName
        self.longName = longName
        self.hasParameter = hasParameter
        self.description = description
    }
    
    func parse() -> (exists: Bool, value: String?) {
        let args = CommandLine.arguments.dropFirst()
        for i in 0..<args.count {
            // If the argument matches
            if args[i] == "-\(self.shortName)" ||
                ((longName != nil) && args[i] == "--\(self.longName!)") {
                // Maybe process the parameter
                var parameter: String? = nil
                if hasParameter {
                    if (i + 1) < args.count {
                        parameter = args[i + 1]
                    }
                }
                return (true, parameter)
            }
        }
        return (false, nil)
    }
}
