@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:::-- Checks the contents for a keyword including date, and the existence or 
::: - non existence of other words. Can search for specific log file or the 
::: - most recently modified file in the location specified. 
:::
:::-- Prerequisites, Dependencies: 
::: -	parameter (config file)
::: -	getDateMinusArg.vbs (to get the CORRECT date)
::: -	getDateFormatVars.bat (to get the Date Variables)
:::
:::-- Accepts the following parameters
::: -%1 = path of config file
:::
:::-- Date formats:
::: ----------------------------------------------------
::: - #dd# - day 2 digits eg 05
::: - #mm# - month 2 digits eg 01
::: - #yyyy# - year 4 digits eg 2012
::: - #yy# - year 2 digits eg 12
::: - #dd1# - day 2 digits yesterday eg 05
::: - #mm1# - month 2 digits yesterday eg 01
::: - #yyyy1# - year 4 digits yesterday eg 2012
::: - #yy1# - year 2 digits yesterday eg 12
::: - #_d# - day 1 digits today eg 5
::: - #_m# - month 1 digit today eg 1
::: - #_d1# - day 1 digits yesterday eg 5
::: - #_m1# - month 1 digits yesterday eg 1
:::
:::-- Accepts the following parameters
::: - %1 = path of config file
:::
:::-- format for values in config values
::: ----------------------------------------------------
::: -  cscript,C:\Windows\System32\cscript
::: -  getdate,getDateMinusArg.vbs (get date vbscript)
::: -  net,C:\Windows\System32\net.exe
::: -  errorfilesin,"PATHOFSHAREDFOLDER"#"USERNAME"#"PASSWORD"#"SUBFOLDERFILE"#"SEARCHNAME1"#"SEARCHNAME2"#"SEARCHNAMENOT1"#"DISPLAYNAME"#"FILEORLOCATION" 
::: -				eg"C:\SyncBack_NI\"#""#""#"Server_DB_Backup_Log.txt"#"#dd#/#mm#/#yyyy#"#""#"error"#"Server DB Backup Copied"#"f"
::: -				eg"\\10.10.10.10\backup"#"10.10.10.10\administrator"#"pass"#"\"#"#_m#/#_d#/#yyyy#"#"Backup completed"#"error"#"10.10.10.10 Daily Backup on #dd#/#mm#/#yyyy#"#"l" 
::: -				NOTE:SEARCHNAME1,SEARCHNAME2 are the phrases to check if they exist. If they don't exist an error is produced.
::: -				NOTE:SEARCHNAMENOT1 is the phrase to check if it does NOT exist. If it exists an error is produced.
::: -				NOTE:FILEORLOCATION "l" finds the last file in the folder "f" finds the spesific file
::: -  find,C:\Windows\System32\find.exe
::: -  notation,^<notation^> (after this notation is the JSON array)
:::
:::-- How to call
::: ----------------------------------------------------
::: - checkLogFileContents.bat configfile.config
:::-- Output 
::: ----------------------------------------------------
::: - JSON file with array of [{"name":"DISPLAYNAME", "value":"ERRORS/OK"}]

::: change directory ***************************CHANGE
::: cd C:\code\win-checks-bats

::: get config values
call getConfigValues.bat %1

:::Get date
call getDateFormatVars.bat

::: replace date formats
SET _errorfilesin=%_errorfilesin:#dd#=!dd!%
SET _errorfilesin=%_errorfilesin:#mm#=!mm!%
SET _errorfilesin=%_errorfilesin:#yyyy#=!yyyy!%
SET _errorfilesin=%_errorfilesin:#yy#=!yy!%
SET _errorfilesin=%_errorfilesin:#dd1#=!dd1!%
SET _errorfilesin=%_errorfilesin:#mm1#=!mm1!%
SET _errorfilesin=%_errorfilesin:#yyyy1#=!yyyy1!%
SET _errorfilesin=%_errorfilesin:#yy1#=!yy1!%
SET _errorfilesin=%_errorfilesin:#_d#=!_d!%
SET _errorfilesin=%_errorfilesin:#_m#=!_m!%
SET _errorfilesin=%_errorfilesin:#_d1#=!_d1!%
SET _errorfilesin=%_errorfilesin:#_m1#=!_m1!%

SET _outJSON=[
::: For all the error files
FOR %%A IN (%_errorfilesin%) DO (
	IF !_hasRecords! EQU 1 (SET _outJSON=!_outJSON! ^,)
	set /a _hasRecords=1

	SET /a _fileFound=0
	SET /a _search1Found=1
	SET /a _search2Found=1
	SET /a _search1NoutFound=1
	SET /a _isFound=0
	SET /a _AlloK=0

	SET _path=""
	SET _username=""
	SET _password=""
	SET _subpath=""
	SET _displayName=""
	SET _filepath=""
	FOR /F "tokens=1,2,3,4,5,6,7,8,9 delims=#" %%B IN ("%%A") DO (
		:::PATHOFSHAREDFOLDER"
		IF %%B == "" (
			call:outError "Starting Path missing"			
		) ELSE (
			SET _path=%%B
			set _path=!_path:"=!
		)
		:::"USERNAME" AND "PASSWORD" if empty do nothing 
		IF NOT %%C == "" (						
			SET _username=%%C
			set _username=!_username:"=!
			:::"PASSWORD"
			IF NOT %%D == "" (		
				SET _password=%%D
				set _password=!_password:"=!			
				!_net! use !_path! /user:!_username! !_password!
			)
		)		
		:::"SUBFOLDERFILE"
		IF %%E == "" (
			call:outError "Subfolder and filename missing"			
		) else (
			SET _subpath=%%E
			set _subpath=!_subpath:"=!
			::: file exists
			SET _filepath=!_path!!_subpath!
			if %%J == "l" (
				SET _filepath=!_path!!_subpath!
				::: Get last updated file 
				for /f "tokens=*" %%q in ('dir "!_filepath!" /b /od') do set _newest=%%q
				SET _filepath=!_filepath!!_newest!
			)	
			
			IF EXIST "!_filepath!" (				
				SET /a _fileFound=1			
				if !_fileFound! EQU 1 (
					:::"SEARCHNAME1" optional
					IF NOT %%F == "" (	
						for /f "tokens=*" %%q in ('!_find! /c /i %%F "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x
						IF !_isFound! GTR 0 (
							set /a _search1Found = 1
						) else (
							set /a _search1Found = 0							
						)					
					)					
					:::"SEAECHNAME2" optional 
					IF NOT %%G == "" (										
						for /f "tokens=*" %%q in ('!_find! /c /i %%G "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x						
						IF !_isFound! GTR 0 (
							set /a _search2Found = 1
						) else (
							set /a _search2Found = 0
						)
					)
					:::"SEARCHNAMENOT1" optional search if it does not exist 
					IF NOT %%H == "" (													
						for /f "tokens=*" %%q in ('!_find! /c /i %%H "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x
						IF !_isFound! EQU 0 (
							set /a _search1NoutFound = 1
						) else (
							set /a _search1NoutFound = 0
						)
					)
				)
			) ELSE (
				SET /a _fileFound=0
			)						
		)		
		
		:::"DISPLAYNAME"
		IF %%I == "" (
			call:outError "Display name missing"				
		) ELSE (
			SET _displayName=%%I
			set _displayName=!_displayName:"=!
		)
		

		:::Make all checks
		IF !_fileFound! EQU 1 ( IF !_search1Found! EQU 1 ( IF !_search2Found! EQU 1 ( IF !_search1NoutFound! EQU 1 (
			SET /a _AlloK=1
		)))) 

		IF !_AlloK! EQU 1 (
			SET _outJSON=!_outJSON! {"name":"!_displayName!","value":"OK"}
		) ELSE (
			SET _outJSON=!_outJSON! {"name":"!_displayName!","value":"ERRORS"}
		)
	)	
)

SET _outJSON=!_outJSON! ]	
@echo !_notation!
@echo !_outJSON!

goto:EOF

:outError
:::--------------------------------------------------------
:::-- Function check that returns error JSON
:::
:::-- Prerequisite: error message
:::
:::-- Accepts the following parameters
::: -%1 = error message
:::
:::-- returns {"error":{"text":"%1"}}
:::--
:::--------------------------------------------------------
@echo !_notation!
@ECHO [{"error":{"text":"%~1"}}]
:::exit
goto:EOF



ENDLOCAL
:::exit