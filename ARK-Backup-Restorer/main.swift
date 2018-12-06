//
//  restoreBackup.swift
//  restoreBackup
//
//  Created by Jonas Frey on 10.01.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

public let usage = "Usage: \(CommandLine.arguments.first!) [-d] <instance> <hh:mm>"

// MARK: Argument Parsing
var useYesterday = false
var time: String
var instance: String

// Remove the first argument (the file name)
var arguments = Array(CommandLine.arguments.dropFirst())

// -d
for i in 0..<arguments.count {
    if arguments[i] == "-d" {
        useYesterday = true
        arguments.remove(at: i)
    }
}

if arguments.count != 2 {
    print(usage)
    exit(EXIT_FAILURE)
}

// instance
instance = arguments.first!
arguments.removeFirst()

// time
// Test if argument is valid
let arg = arguments.first!
let timeRegex = "^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
if arg.range(of: timeRegex, options: .regularExpression, range: nil, locale: nil) == nil {
    // Wrong format
    print("Illegal time format. Use 'hh:mm'")
    exit(EXIT_FAILURE)
}
// Get time
time = arg.replacingOccurrences(of: ":", with: ".")
arguments.removeFirst()

if !arguments.isEmpty {
    print("Too many arguments provided!")
    exit(EXIT_FAILURE)
}

// MARK: Execution
let controller = BackupController(instance: instance, time: time, isYesterday: useYesterday)
controller.restoreBackup()

exit(EXIT_SUCCESS)

