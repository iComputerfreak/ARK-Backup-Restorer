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
    let commandOptions: [Option]
    
    init(usage: String, commandOptions: [Option]) {
        self.command = CommandLine.arguments.first!
        self.args = Array(CommandLine.arguments.dropFirst())
        self.usage = usage
        self.commandOptions = commandOptions
    }
    
    func parseArguments(args: [String]) -> [(exists: Bool, value: String?)] {
        var results = [(Bool, String?)]()
        for option in commandOptions {
            results.append(option.parse())
        }
        return results
    }
    
    /// Prints the usage
    func printUsage() {
        log(usage)
    }
    
    /// Prints the usage and information for all arguments
    func printHelp() {
        log(usage)
        for option in commandOptions {
            log(option.description)
        }
    }
    
    /// Writes an message to the respective stream
    ///
    /// - Parameter message: The message to write
    /// - Parameter error: Whether the message is an error message
    func log(_ message: String, error: Bool = false) {
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
    func logError(_ message: String) {
        log(message, error: true)
    }
    
}
