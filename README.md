windows-checks-bats
===================

Batch files to do basic IT checks such as ping test, check log files etc.

These scripts output a JSON Array but can easily be changed to output anything else. 

Why?
----

Needed to automate basic IT checks in an environment with different technologies and setups. Tried to make the scripts as flexible as possible. They are not complete and surely not perfect, but could be useful to someone so here they are.

Installation
------------

	Just download the files in a folder on your windows PC

Output
------
Prints on the screen a **notation** and on the next line the **JSON Array** with the results. The notation is printed to help applications recognize when the JSON Array begins. 
For example:
 ```json
<notation>[ {"name":"10.10.10.10","value":"YES"} 
, {"name":"10.10.10.11","value":"YES"} 
, {"name":"10.10.10.12","value":"NO"} 
, {"name":"10.10.10.13","value":"YES"} ]
```

Scripts
-------

- [pingTest.bat]
- [checkNTBackup.bat]
- [checkNetworkDiskSpace.bat]
- [checkLogFileExists.bat]
- [checkLogFileContents.bat]

### pingTest.bat

Performs ping on the IPs given and returns a JSON array 

**Usage**

	pingTest.bat target1 target2

**Output**

```json
<notation>[{"name":"DISPLAYNAME", "value":"YES/NO"},...]
```

### checkNTBackup.bat

Checks ntbackup logs. Finds the latest log file in the folder and looks for date (as defined by date format), counts the number of Backup Complete and Backup Verified, as defined in config file. Also checks if the word error exists.All phrases that are searched are defined in the config file as they can be different depending on the localization. 
Idea was taken from [ntbackup-logcheck]

**Dependencies**

    - getDateMinusArg.vbs (to get the CORRECT date)
    - getDateFormatVars.bat (to get the Date Variables)

**Usage**

    checkNTBackup.bat configfile.config

**Config Input**

    - cscript,C:\Windows\System32\cscript
    - getdate,getDateMinusArg.vbs (get date vbscript)
    - net,C:\Windows\System32\net.exe
    - logfilein,"PATHOFSHAREDFOLDER"#"USERNAME"#"PASSWORD"#"DATEFORMAT"#NOOFCOMPLETED"#"NOOFVERIFIED"#"DISPLAYNAME" 
    e.g. _logfilein,"\\BackupServer"#"BackupServer\administrator"#"password"#"#d#/#m#/#yyyy#"#"3"#"0"#"Backups from server."
    - backupComplete,Backup completed (localization)
    - verifyCompleted,Verify completed (localization)
    - errorStr,Error (localization)
    - find,C:\Windows\System32\find.exe
    - notation,^<notation^> (after this notation is the JSON array)

**Output**

```json
<notation>[{"name":"DISPLAYNAME", "value":"ERRORS/OK"},...]
```

### checkNetworkDiskSpace.bat

Checks the free space in bytes using shared folders. 

**Dependencies**

    - getDateMinusArg.vbs (to get the CORRECT date)

**Usage**

    checkNetworkDiskSpace.bat configfile.config

**Config Input**

	- cscript,C:\Windows\System32\cscript
	- net,C:\Windows\System32\net.exe
	- getdate,..\scripts\getDateMinusArg.vbs (get date vbscript)
	- checkdisksizepaths,PATHOFSHAREDFOLDER:USERNAME:PASSWORD:TEMPDRIVE#DISPLAYNAME eg\\10.10.10.10\temp:10.10.10.10\administrator:pass:o#10.10.10.10
	- notation,^<notation^> (after this notation is the JSON array)
	
**Output**

```json
<notation>[{"name":"DISPLAYNAME", "value":"SIZEinBytes"},...]
```

### checkLogFileExists.bat

Checks if log files with specific format (including date) exists and returns JSON Array

**Dependencies**

	-	getDateMinusArg.vbs (to get the CORRECT date)
	-	getDateFormatVars.bat (to get the Date Variables)

**Usage**

    checkLogFileExists.bat configfile.config

**Config Input**

	-  cscript,C:\Windows\System32\cscript
	-  servicesfolder,log files folder must be shared folder eg \\10.10.10.10\Services
	-  net,C:\Windows\System32\net.exe
	-  getdate,getDateMinusArg.vbs (get date vbscript)
	-  login,log files server login eg administrator pass
	-  errorfilesin,PATHOFFILE#"DISPLAYNAME" e.g. \ServiceSubfolder\logs\#yyyy#-#mm#-#dd#\error.log:"Something Generator Service on #yyyy#-#mm#-#dd#" 
	- 				NOTE: PATHOFFILE can also have #STAR#
	-  notation,^<notation^> (after this notation is the JSON array)
	
**Output**

```json
<notation>[{"name":"DISPLAYNAME", "value":"ERRORS/OK"},...]
```

### checkLogFileContents.bat

Checks the contents for a keyword including date, and the existence or non existence of phrases. Can search for specific log file or the most recently modified file in the location specified.

**Dependencies**

	-	getDateMinusArg.vbs (to get the CORRECT date)
	-	getDateFormatVars.bat (to get the Date Variables)

**Usage**

    checkLogFileContents.bat configfile.config

**Config Input**

	-  cscript,C:\Windows\System32\cscript
	-  getdate,getDateMinusArg.vbs (get date vbscript)
	-  net,C:\Windows\System32\net.exe
	-  errorfilesin,"PATHOFSHAREDFOLDER"#"USERNAME"#"PASSWORD"#"SUBFOLDERFILE"#"SEARCHNAME1"#"SEARCHNAME2"#"SEARCHNAMENOT1"#"DISPLAYNAME"#"FILEORLOCATION" 
	-				eg"C:\SyncBack_NI\"#""#""#"Server_DB_Backup_Log.txt"#"#dd#/#mm#/#yyyy#"#""#"error"#"Server DB Backup Copied"#"f"
	-				eg"\\10.10.10.10\backup"#"10.10.10.10\administrator"#"pass"#"\"#"#_m#/#_d#/#yyyy#"#"Backup completed"#"error"#"10.10.10.10 Daily Backup on #dd#/#mm#/#yyyy#"#"l" 
	-				NOTE:SEARCHNAME1,SEARCHNAME2 are the phrases to check if they exist. If they don't exist an error is produced.
	-				NOTE:SEARCHNAMENOT1 is the phrase to check if it does NOT exist. If it exists an error is produced.
	-				NOTE:FILEORLOCATION "l" finds the last file in the folder "f" finds the spesific file
	-  find,C:\Windows\System32\find.exe
	-  notation,^<notation^> (after this notation is the JSON array
	
**Output**

```json
<notation>[{"name":"DISPLAYNAME", "value":"ERRORS/OK"},...]
```

License
-------

The MIT License (MIT)

Copyright (c) 2013 gieglas
[ntbackup-logcheck]: http://www.heinzi.at/projects/ntbackup-logcheck/
[pingTest.bat]:#pingtestbat
[checkNTBackup.bat]:#checkntbackupbat
[checkNetworkDiskSpace.bat]:#checknetworkdiskspacebat
[checkLogFileExists.bat]:#checklogfileexistsbat
[checkLogFileContents.bat]:#checklogfilecontentsbat