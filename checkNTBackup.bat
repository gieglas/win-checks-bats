@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:::-- Checks ntbackup logs. Finds the latest log file in the folder and looks for date 
::: - (as defined by date format), counts the number of Backup Complete and 
::: - Backup Verified, as defined in config file. Also checks if the word error exists.
::: - All phrases that are search are defined in the config file as they can be different
::: - depending on the localization. 
::: - Idea was taken from http://www.heinzi.at/projects/ntbackup-logcheck/ 
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
::: -  logfilein,"PATHOFSHAREDFOLDER"#"USERNAME"#"PASSWORD"#"DATEFORMAT"#NOOFCOMPLETED"#"NOOFVERIFIED"#"DISPLAYNAME" 
:::	  	e.g. _logfilein,"\\BackupServer"#"BackupServer\administrator"#"password"#"#d#/#m#/#yyyy#"#"3"#"0"#"Backups from server."
::: -  backupComplete,Backup completed (localization)
::: -  verifyCompleted,Verify completed (localization)
::: -  errorStr,Error (localization)
::: -  find,C:\Windows\System32\find.exe
::: -  notation,^<notation^> (after this notation is the JSON array)
:::
:::-- How to call
::: ----------------------------------------------------
::: - checkNTBackup.bat configfile.config
:::-- Output 
::: ----------------------------------------------------
::: - JSON file with array of [{"name":"DISPLAYNAME", "value":"ERRORS/OK"},...] after the notation ^<notation^>

::: change directory ***************************CHANGE
::: cd C:\code\win-checks-bats

::: get config values
call getConfigValues.bat %1

:::Get date
call getDateFormatVars.bat

::: replace date formats
SET _logfilein=%_logfilein:#dd#=!dd!%
SET _logfilein=%_logfilein:#mm#=!mm!%
SET _logfilein=%_logfilein:#yyyy#=!yyyy!%
SET _logfilein=%_logfilein:#yy#=!yy!%
SET _logfilein=%_logfilein:#dd1#=!dd1!%
SET _logfilein=%_logfilein:#mm1#=!mm1!%
SET _logfilein=%_logfilein:#yyyy1#=!yyyy1!%
SET _logfilein=%_logfilein:#yy1#=!yy1!%
SET _logfilein=%_logfilein:#_d#=!_d!%
SET _logfilein=%_logfilein:#_m#=!_m!%
SET _logfilein=%_logfilein:#_d1#=!_d1!%
SET _logfilein=%_logfilein:#_m1#=!_m1!%

SET _outJSON=[
::: For all the error files
FOR %%A IN (%_logfilein%) DO (
	IF !_hasRecords! EQU 1 (SET _outJSON=!_outJSON! ^,)
	set /a _hasRecords=1

	SET /a _isFound=0
	SET /a _AlloK=1

	SET _path=""
	SET _username=""
	SET _password=""
	SET _dateFormat=""
	SET /a _backupCompleteNo=0
	SET /a _verifyCompleteNo=0
	SET _displayName=""	
	FOR /F "tokens=1,2,3,4,5,6,7 delims=#" %%B IN ("%%A") DO (
		:::PATHOFSHAREDFOLDER
		IF %%B == "" (
			call:outError "Starting Path missing"
		) ELSE (
			SET _path=%%B
			set _path=!_path:"=!
		)
		:::USERNAME AND PASSWORD if empty do nothing 
		IF NOT %%C == "" (						
			SET _username=%%C
			set _username=!_username:"=!
			:::"PASSWORD"
			IF NOT %%D == "" (		
				SET _password=%%D
				set _password=!_password:"=!
				::: perform net use								
				!_net! use !_path! /user:!_username! !_password!
			)
		)		
				
		::: Get last updated file 
		for /f "tokens=*" %%q in ('dir "!_path!\" /b /od') do set _newest=%%q
		SET _filepath=!_path!\!_newest!

		:::DATEFORMAT
		IF %%E == "" (
			call:outError "DATE FORMAT missing"
		) ELSE (			
			SET _dateFormat=%%E
		)

		:::NOOFCOMPLETED
		IF %%F == "" (
			call:outError "NO OF COMPLETED missing"
		) ELSE (
			SET _backupCompleteNoStr=%%F
			set _backupCompleteNoStr=!_backupCompleteNoStr:"=!
			set /a _backupCompleteNo=!_backupCompleteNoStr
		)

		:::NOOFVERIFIED
		IF %%G == "" (
			call:outError "NO OF VERIFIED missing"
		) ELSE (
			SET _verifyCompleteNoStr=%%G
			set _verifyCompleteNoStr=!_verifyCompleteNoStr:"=!
			set /a _verifyCompleteNo=!_verifyCompleteNoStr
		)

		:::DISPLAYNAME
		IF %%H == "" (
			call:outError "Display name missing"
		) ELSE (
			SET _displayName=%%H
			set _displayName=!_displayName:"=!
		)		

		IF EXIST "!_filepath!" (						
			:::error
			for /f "tokens=*" %%q in ('!_find! /c /i !_errorStr! "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x 			
			IF !_isFound! GTR 0 (
				set /a _AlloK=0
			)		
			:::dateformat	
			for /f "tokens=*" %%q in ('!_find! /c /i !_dateFormat! "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x 
			IF !_isFound! EQU 0 (
				set /a _AlloK=0
			)			
			:::Count _backupCompleteNo
			for /f "tokens=*" %%q in ('!_find! /c /i !_backupComplete! "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x						
			IF !_isFound! NEQ !_backupCompleteNo! (
				set /a _AlloK=0
			)			
			:::Count _verifyCompleteNo
			for /f "tokens=*" %%q in ('!_find! /c /i !_verifyComplete! "!_filepath!"') do for %%x in (%%q) do set /a _isFound=%%x						
			IF !_isFound! NEQ !_verifyCompleteNo! (
				set /a _AlloK=0
			)			
		) ELSE (
			call:outError "File not found"
		)								

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