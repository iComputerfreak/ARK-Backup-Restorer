//
//  restoreBackup.swift
//  restoreBackup
//
//  Created by Jonas Frey on 10.01.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

@discardableResult
func shell(launchPath: String, dir: String, arguments: String...) -> String {
    let task = Process()
    task.currentDirectoryPath = dir
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: String.Encoding.utf8)!
    
    return output
}

// MARK: Preparation
let formatter = DateFormatter()
var backupTime = ""


// MARK: Argument Parsing

let usage = "Usage: \(CommandLine.arguments.first!) [-d] <instance> [hh:mm]"

// Arguments
var useYesterday = false
var time: String
var instance: String

var arguments = Array(CommandLine.arguments.dropFirst())

// -d
for i in 0..<arguments.count {
    if arguments[i] == "-d" {
        useYesterday = true
        arguments.remove(at: i)
    }
}

// instance
if arguments.isEmpty {
    print(usage)
    exit(EXIT_FAILURE)
}
instance = arguments.first!
arguments.removeFirst()

// time
if !arguments.isEmpty {
    // Test if argument is valid
    let arg = arguments.first!
    let timeRegex = "^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
    if arg.range(of: timeRegex, options: .regularExpression, range: nil, locale: nil) == nil {
        // Wrong format
        print("Illegal time format. Use 'hh:mm'")
        exit(EXIT_FAILURE)
    }
    // Get time
    backupTime = arg.replacingOccurrences(of: ":", with: ".")
    arguments.removeFirst()
}

if !arguments.isEmpty {
    print("Too many arguments provided!")
    exit(EXIT_FAILURE)
}

// MARK: Execution

formatter.dateFormat = "yyyy-MM-dd"
var date = Date()
if useYesterday {
    // Set the date to yesterday
    date.addTimeInterval(-1 * 60 * 60 * 24)
}
let backupDay = formatter.string(from: date)

// If no time provided by argument
if backupTime.isEmpty {
    formatter.dateFormat = "HH.mm"
    backupTime = formatter.string(from: Date())
    // round the time down, so we get a time modulo 10 minutes
    backupTime.removeLast()
    backupTime += "0"
}

// MARK: Define directories
let home = FileManager.default.homeDirectoryForCurrentUser.path
let backupDayDirectory = "\(home)/ARK-Backups/\(backupDay)"
var unzippedFolder = "\(backupDayDirectory)/\(backupDay)_\(backupTime)"
var backupZipFilePath = "\(backupDayDirectory)/the_island.\(backupDay)_\(backupTime)"
var destination = "\(home)/\(instance)/ShooterGame/Saved/SavedArks"
//var destination = "\(home)/test"
//print("[WARNING] Debug Destination set to \(destination)")

// Get exact second of backup (find matching file name)
for i in 0...9 {
    if FileManager.default.fileExists(atPath: "\(backupZipFilePath).0\(i).tar.bz2") {
        backupZipFilePath += ".0\(i).tar.bz2"
        unzippedFolder += ".0\(i)"
        break
    }
}

// Exact Zipfile name
let backupZipFileName = backupZipFilePath.components(separatedBy: "/").last!.dropLast(8)

print("Destination: \(destination)")
if !FileManager.default.fileExists(atPath: destination) {
    print("Invalid instance")
    exit(EXIT_FAILURE)
}

//print("Backup directory: \(backupDayDirectory)")
print("Accessing backup file \(backupZipFileName).tar.bz2")

if !backupZipFilePath.hasSuffix(".tar.bz2") {
    // File did not exist
    print("The backup for the given time does not exist")
    exit(EXIT_FAILURE)
}

// Decompressing archive
let output = shell(launchPath: "/bin/tar", dir: "\(backupDayDirectory)", arguments: "-xf", backupZipFilePath)
if !output.isEmpty {
    print("tar: \(output)")
}

print("Restoring backup...")

do {
    let fileManager = FileManager.default
    // Backup the current savegame
    if fileManager.fileExists(atPath: "\(destination).old") {
        print("  Removing old data folder")
        try fileManager.removeItem(atPath: "\(destination).old")
    }
    print("  Backing up data folder")
    try fileManager.moveItem(atPath: destination, toPath: "\(destination).old")
    print("  Creating new data folder")
    try fileManager.createDirectory(atPath: destination, withIntermediateDirectories: false)
    // Restore the backup
    print("  Getting contents of \(unzippedFolder)")
    let contents = try fileManager.contentsOfDirectory(atPath: unzippedFolder)
    print("  Moving files")
    for file in contents {
        // print("    \(file)")
        try fileManager.moveItem(atPath: "\(unzippedFolder)/\(file)", toPath: "\(destination)/\(file)")
    }
    print("Removing decompressed backup")
    // Remove the folder
    try fileManager.removeItem(atPath: unzippedFolder)
} catch {
    print("Error while restoring backup!")
    print(error)
    exit(EXIT_FAILURE)
}

print("Backup successfully restored.")

exit(EXIT_SUCCESS)

