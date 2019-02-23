//
//  BackupController.swift
//  ARK-Backup-Restorer
//
//  Created by Jonas Frey on 04.12.18.
//  Copyright © 2018 Jonas Frey. All rights reserved.
//

import Foundation

class BackupController {
    
    let backupFolder = "Backups/"
    
    let savegameFolder: String
    let instance: String
    var backupTime: String
    let backupDay: String
    let basePath: String
    
    init(savegameFolder: String, instance: String, time: String, isYesterday: Bool) {
        let formatter = DateFormatter()
        
        self.savegameFolder = savegameFolder
        self.instance = instance
        self.backupTime = time
        // If no time provided by argument, use now
        if time.isEmpty {
            formatter.dateFormat = "HH.mm"
            self.backupTime = formatter.string(from: Date())
            // round the time down, so we get a time modulo 10 minutes
            self.backupTime.removeLast()
            self.backupTime += "0"
        }
        
        // Set the backup day
        formatter.dateFormat = "yyyy-MM-dd"
        var date = Date()
        if isYesterday {
            // Set the date to yesterday
            date.addTimeInterval(-1 * 60 * 60 * 24)
        }
        self.backupDay = formatter.string(from: date)
        
        // Set the basePath to the home directory
        var path: String
        if #available(OSX 10.12, *) {
            path = FileManager.default.homeDirectoryForCurrentUser.path
        } else {
            // Fallback on earlier versions
            path = NSHomeDirectory()
        }
        if path.last! != "/" {
            path += "/"
        }
        basePath = path
    }
    
    func restoreBackup() {
        // the backup zip file (full path)
        guard let zip = getBackupFile() else {
            print("Error getting backup file!")
            exit(EXIT_FAILURE)
        }
        
        // the folder with the contents of the extracted zip
        var sourceFolder = "/tmp/" + String(zip.components(separatedBy: "/").last!.dropLast(8)) + "/"
        // the source foldes does not contain the instance name
        sourceFolder = sourceFolder.replacingOccurrences(of: "\(instance).", with: "")
        // the ark savegame directory (/Saved/SavedArks/)
        let destination = basePath + savegameFolder + "/ShooterGame/Saved/SavedArks/"
        
        // Check, if the savegame directory exists
        if !FileManager.default.fileExists(atPath: destination) {
            print("Invalid savegame folder: " + destination)
            exit(EXIT_FAILURE)
        }
        
        // Check, if the backup file for the given time exists
        if !FileManager.default.fileExists(atPath: zip) {
            print("Backup file " + zip + " does not exist!")
        }
        
        print("Backup found: " + zip)
        print("Destination: " + destination)
        print("Extracting Backup...")
        
        // Decompressing archive into /tmp
        let output = shell(launchPath: "/bin/tar", dir: "/tmp", arguments: "-xf", zip)
        if !output.isEmpty {
            print("tar: \(output)")
        }
        
        print("Restoring backup...")
        
        // Restore the contents of the extracted folder in /tmp into the save game directory
        restore(sourceFolder: sourceFolder, destinationFolder: destination)
        
        print("Backup successfully restored.")

    }
    
    private func getBackupFile() -> String? {
        let folder = basePath + backupFolder + backupDay + "/"
        // Sets the file name with the time (rounded down to 10) without the seconds
        let filename = instance + "." + backupDay + "_" + backupTime
        // Get exact second of backup (find matching file name)
        for i in 0...9 {
            if FileManager.default.fileExists(atPath: "\(folder + filename).0\(i).tar.bz2") {
                // Found a valid backup file
                return folder + filename + ".0\(i).tar.bz2"
            }
        }
        print("No backup found!")
        return nil
    }
    
    private func restore(sourceFolder: String, destinationFolder: String) {
        do {
            let fileManager = FileManager.default
            // Remove the savegame backup that was created last time
            if fileManager.fileExists(atPath: "\(destinationFolder).old") {
                print("  Removing old data folder")
                try fileManager.removeItem(atPath: "\(destinationFolder).old")
            }
            
            print("  Backing up data folder")
            try fileManager.moveItem(atPath: destinationFolder, toPath: "\(destinationFolder.dropLast()).old/")
            print("  Creating new data folder")
            try fileManager.createDirectory(atPath: destinationFolder, withIntermediateDirectories: false)
            
            // Restore the backup
            print("  Getting contents of \(sourceFolder)")
            let contents = try fileManager.contentsOfDirectory(atPath: sourceFolder)
            print("  Moving files")
            for file in contents {
                print("    \(file)")
                try fileManager.moveItem(atPath: "\(sourceFolder)\(file)", toPath: "\(destinationFolder)\(file)")
            }
            
            print("Removing extracted backup...")
            // Remove the folder
            try fileManager.removeItem(atPath: sourceFolder)
        } catch {
            print("Error while restoring backup!")
            print(error)
            print("  sourceFolder: " + sourceFolder)
            print("  destinationFolder: " + destinationFolder)
            exit(EXIT_FAILURE)
        }
    }
    
    /// Run a shell command
    @discardableResult
    private func shell(launchPath: String, dir: String, arguments: String...) -> String {
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
    
    
    
}
