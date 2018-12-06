# ARK-Backup-Restorer
I built this tool to restore the backups I made with the [ark server tools from FezVrasta](https://github.com/FezVrasta/ark-server-tools). The script gets the correct `.tar.bz2` file from the backup directory, unzips it and copys the contents in the right directory (moving the old savegame to a separate `SavedArks.old` folder).

## How to compile the script on Linux
* Install Swift from [http://www.swift.org](http://www.swift.org)
* Run `swiftc -o restoreBackup path/to/main.swift path/to/BackupController.swift`
* The executable `restoreBackup` has been built

## Usage
`./restoreBackup [-d] <savegame folder> <instance> <hh:mm>`

Argument 				| Explanation
---		 				| ---
`-d`       			| Restore a backup from yesterday. If not set, the script will restore a backup from today
`savegame folder` 	| The exact name of the folder in your home directory, where the ark instance is located. (The folder where the ShooterGame subfolder is located in)
`instance` 			| The name of the arkmanager instance
`hh:mm`    			| The time of the backup to restore
