# ARK-Backup-Restorer
I build this tool to restore the backups I made with the ark server tool from FezVrasta. The script gets the correct `.tar.bz2` file from the backup directory, unzips it and copys the contents in the right directory (moving the old savegame to a separate `SavedArks.old` folder).

## How to compile the script on Linux
* Install Swift from [http://www.swift.org]()
* Run `swiftc restoreBackup.swift`
* The executable `restoreBackup` has been built

## Usage
`./restoreBackup [-d] <instance> <hh:mm>`

Argument | Explanation
-------- | -----------
-d       | Restore a backup from yesterday. If not set, the script will restore a backup from today
instance | The exact name of the folder in your home directory, where the ark instance is located. (The folder where the ShooterGame subfolder is located in)
hh:mm    | The time of the backup to restore