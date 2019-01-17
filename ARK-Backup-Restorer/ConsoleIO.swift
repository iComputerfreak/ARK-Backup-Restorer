//
//  ConsoleIO.swift
//  ARK-Backup-Restorer
//
//  Created by Jonas Frey on 10.12.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

class ConsoleIO {
    
    let command: String
    let args: [String]
    let usage: String
    let commandArguments: [Argument]
    // TODO: commandOptions should FIRST contain all arguments, THEN all Options
    
    init(usage: String, commandArguments: [Argument]) {
        self.command = CommandLine.arguments.first!
        self.args = Array(CommandLine.arguments.dropFirst())
        self.usage = usage
        self.commandArguments = commandArguments
        distributeRawValues()
    }
    
    // TODO: Arguments do not need to be first in the commandOptions
    func distributeRawValues() {
        var arguments = args
        // First, parse all arguments
        for arg in commandArguments.filter({ (arg: Argument) -> Bool in return !(arg is Option) }) {
            guard arguments.count > 0 else {
                // TODO: Really needed?
                ConsoleIO.logError("Not enough arguments specified")
                printUsage()
                return
            }
            // Check if the input argument is an option
            if arguments.first!.starts(with: "-") {
                ConsoleIO.logError("Not enough arguments specified")
                printUsage()
                return
            }
            arg.rawArgument = arguments.removeFirst()
        }
        // Now parse all options
        for arg in commandArguments.filter({ (arg: Argument) -> Bool in return arg is Option }) {
            let option = arg as! Option
            // TODO: Parse
            let i = max(arguments.firstIndex(of: "-\(option.shortName)"),
                        arguments.firstIndex(of: "--\(option.longName)"))
            if i < 0 {
                // ERROR!
            }
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
    }
    
    // TODO: Arguments can only be parsed here
    
    func parseArguments() throws -> [String: (exists: Bool, value: String?)] {

        
        let args = CommandLine.arguments.dropFirst()
        for i in 0..<args.count {
            // If the argument matches
           
        }
        return (false, nil)
    }
    
    /// Prints the usage
    func printUsage() {
        ConsoleIO.log(usage)
    }
    
    /// Prints the usage and information for all arguments
    func printHelp() {
        ConsoleIO.log(usage)
        for option in commandOptions {
            ConsoleIO.log(option.description)
        }
    }
    
    /// Writes an message to the respective stream
    ///
    /// - Parameter message: The message to write
    /// - Parameter error: Whether the message is an error message
    class func log(_ message: String, error: Bool = false) {
        if (error) {
            // Write the error to stderr
            fputs(message, stderr)
        } else {
            // Write the message to stdout
            print(message)
        }
    }
    
    
    /// Writes an error to stderr
    ///
    /// - Parameter message: The error message to write
    class func logError(_ message: String) {
        log(message, error: true)
    }
    
}
