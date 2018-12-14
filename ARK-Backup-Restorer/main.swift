//
//  restoreBackup.swift
//  restoreBackup
//
//  Created by Jonas Frey on 10.01.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

/* ! Options with more than one parameter (or parameters containing spaces) are currently not supported ! */

// Define the usage and the options of the program
let commandOptions: [Option] = [
    Option(shortName: "h", longName: "help", hasParameter: false, description: ""),
    Option(shortName: "d", longName: "yesterday", hasParameter: false, description: "")
]
let io = ConsoleIO(
    usage: "Usage: \(CommandLine.arguments.first!) [-d] <savegame folder> <instance> <hh:mm>",
    commandOptions: commandOptions)

// MARK: Argument Parsing
let useYesterday = commandOptions[1].parse().exists
var time: String
var savegameFolder: String
var instance: String

// Remove the first argument (the file name)
var arguments = Array(CommandLine.arguments.dropFirst())

// there should be 3 or 4 arguments left
if arguments.count != (useYesterday ? 4 : 3) {
    io.printUsage()
    exit(EXIT_FAILURE)
}

// savegame folder
savegameFolder = arguments.first!
arguments.removeFirst()

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
let controller = BackupController(savegameFolder: savegameFolder, instance: instance, time: time, isYesterday: useYesterday)
controller.restoreBackup()

exit(EXIT_SUCCESS)

// TODO: Pass a closure to determine, if the given string argument fits the expected pattern and maybe an error message, if not?
// TODO: Add generic type to the option, to automatically parse the return value of parse()

// TODO: Somehow process the required arguments (the args without an option)

/*
 Argument: description, type, check-closure
 - Option: short name, long name, has parameter?
 */

// TODO: Move the parsing from the options to the ConsoleIO (go through the arguments only one time)
